# coding: utf-8

# A client for the GMO Payment API.
#
# example
# gmo = GMO::Payment::ShopAndSiteAPI.new({
#   site_id:     "foo",
#   site_pass:   "bar",
#   shop_id:     "baz",
#   shop_pass:   "bax",
#   host:        "p01.mul-pay.jp",
#   locale:      "ja"
# })
module GMO
  module Payment

    module ShopAndSiteAPIMethods
      def initialize(options = {})
        @shop_id   = options[:shop_id]
        @shop_pass = options[:shop_pass]
        @site_id   = options[:site_id]
        @site_pass = options[:site_pass]
        @host      = options[:host]
        @locale    = options.fetch(:locale, GMO::Const::DEFAULT_LOCALE)
        unless @site_id && @site_pass && @shop_id && @shop_pass && @host
          raise ArgumentError, "Initialize must receive a hash with :site_id, :site_pass, :shop_id, :shop_pass and either :host! (received #{options.inspect})"
        end
      end
      attr_reader :shop_id, :shop_pass, :site_id, :site_pass, :host, :locale

      # 2.17.2.1.決済後カード登録
      # 指定されたオーダーID の取引に使用したカードを登録します。
      ### @return ###
      # CardSeq
      # CardNo
      # Forward
      def trade_card(options = {})
        name = "TradedCard.idPass"
        required = [:order_id, :member_id]
        assert_required_options(required, options)
        post_request name, options
      end

      ### @params ###
      # MemberID
      # OrderID
      # DefaultFlag
      # SeqMode
      ### @return ###
      # TokenSeq
      # CardNoToken
      # Forward
      ### example ###
      # gmo.trade_brandtoken({
      #   member_id: 'mem10001',
      #   order_id: 'ord10001'
      # })
      # => {"TokenSeq"=>"0", "CardNoToken"=>"*************111", "Forward"=>"2a99663"}
      def trade_brandtoken(options = {})
        name = "TradedBrandtoken.idPass"
        required = [:order_id, :member_id]
        assert_required_options(required, options)
        post_request name, options
      end

      ### @params ###
      # AccessID
      # AccessPass
      # OrderID
      # TokenType
      # Token
      # MemberID
      # SeqMode
      # TokenSeq
      # ClientField1
      # ClientField2
      # ClientField3
      ### @return ###
      # Status
      # OrderID
      # Forward
      # Approve
      # TranID
      # TranDate
      # ClientField1
      # ClientField2
      # ClientField3
      ### example ###
      # gmo.exec_tran_brandtoken({
      #   order_id: "597ae8c36120b23a3c00014e",
      #   access_id: "139f8ec33a07c55f406937c52ce4473d",
      #   access_pass: "2689b204d2c17192fa35f9269fa7e744",
      #   token_type: :apple_pay,
      #   token: <Base64 encoded payment data>,
      #   member_id: "mem10001"
      # })
      # => {"Status"=>"CAPTURE", "OrderID"=>"597ae8c36120b23a3c00014e", "Forward"=>"2a99663", "Approve"=>"5487394", "TranID"=>"1707281634111111111111771216", "TranDate"=>"20170728163453", "ClientField1"=>"Custom field value 1", "ClientField2"=>"Custom field value 2", "ClientField3"=>"Custom field value 3"}
      def exec_tran_brandtoken(options = {})
        name = "ExecTranBrandtoken.idPass"
        options[:token_type] = GMO::Const::TOKEN_TYPES_MAP[options[:token_type]]
        required = [:access_id, :access_pass, :member_id, :order_id]
        assert_required_options(required, options)
        post_request name, options
      end

      ### @params ###
      # ShopID
      # ShopPass
      # RecurringID
      # Amount
      # Tax
      # ChargeDay
      # ChargeMonth
      # ChargeStartDate
      # ChargeStopDate
      # RegistType
      # SiteID
      # SitePass
      # MemberID
      # CardNo
      # Expire
      # SrcOrderID
      # ClientField1
      # ClientField2
      # ClientField3
      ### @return ###
      # ShopID
      # RecurringID
      # Amount
      # Tax
      # ChargeDay
      # ChargeMonth
      # ChargeStartDate
      # ChargeStopDate
      # NextChargeDate
      # Method
      ### example ###
      # gmo.register_recurring_credit({
      #   recurring_id: "1535964921",
      #   amount: 100,
      #   regist_type: GMO::Const::RECURRING_REGIST_TYPE[:member_id],
      #   member_id: "mem10001"
      # })
      # => {"ShopID"=>"tshop0001", "RecurringID"=>"1535964921", "Amount"=>"100", "Tax"=>"0", "ChargeDay"=>"31", "ChargeMonth"=>"01|02|03|04|05|06|07|08|09|10|11|12", "ChargeStartDate"=>"20180904", "ChargeStopDate"=>"", "NextChargeDate"=>"20180930", "Method"=>"RECURRING_CREDIT", "CardNo"=>"", "Expire"=>"", "SiteID"=>"", "MemberID"=>"mem1001"}
      def register_recurring_credit(options = {})
        name = "RegisterRecurringCredit.idPass"
        required = [:recurring_id, :charge_day, :amount, :regist_type]
        required += case options[:regist_type].to_i
                    when 1
                      options.update(site_id: @site_id, site_pass: @site_pass)
                      [:member_id]
                    when 2
                      [:card_no, :expire]
                    when 3
                      [:src_order_id]
                    end
        assert_required_options(required, options)
        post_request name, options
      end

      ### @params ###
      # ShopID
      # ShopPass
      # RecurringID
      ### @return ###
      # ShopID
      # RecurringID
      # Amount
      # Tax
      # ChargeDay
      # ChargeMonth
      # ChargeStartDate
      # ChargeStopDate
      # NextChargeDate
      # Method
      # SiteID
      # MemberID
      # CardNo
      # Expire
      # PrintStr
      # ErrCode
      # ErrInfo
      ### example ###
      # gmo.unregister_recurring({
      #   recurring_id: "1535964921"
      # })
      # => {"ShopID"=>"tshop0001", "RecurringID"=>"1536039145", "Amount"=>"100", "Tax"=>"0", "ChargeDay"=>"31", "ChargeMonth"=>"01|02|03|04|05|06|07|08|09|10|11|12", "ChargeStartDate"=>"20180905", "ChargeStopDate"=>"", "NextChargeDate"=>"", "Method"=>"RECURRING_CREDIT", "CardNo"=>"", "Expire"=>"", "SiteID"=>"tsite0001", "MemberID"=>"mem1001", "PrintStr"=>""}
      def unregister_recurring(options = {})
        name = "UnregisterRecurring.idPass"
        options.merge!(site_id: @site_id, site_pass: @site_pass)
        required = [:recurring_id]
        assert_required_options(required, options)
        post_request name, options
      end

      private

        def api_call(name, args = {}, verb = "post", options = {})
          args.merge!({
            "ShopID"   => @shop_id,
            "ShopPass" => @shop_pass,
            "SiteID"   => @site_id,
            "SitePass" => @site_pass
          })
          api(name, args, verb, options) do |response|
            if response.is_a?(Hash) && !response["ErrInfo"].nil?
              raise APIError.new(response, locale)
            end
          end
        end

    end
  end
end
