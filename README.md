ML AS SDK
=============

初始化：init()
--------------

public static function init(serviceName:String, lang:String, apiKey:String, callBack:Function):void

通过该方法初始化ML。初始化后即可通过ML.trans()翻译词句、通过ML.transUrl()获取目标语言地址。需要先登陆行云管理系统创建多语言服务 http://p.xingcloud.com

#### 参数类型

* serviceName: String - 服务名称, 如 "my_ml_test"
* apiKey: String - 行云多语言管理系统分配的API密钥, 如 "21f...e35"
* sourceLang: String - 原始语言, 如"cn"
* targetLang: String - 目标语言, 如"en", 直接从行云传递给应用的flashVars里取得
* autoAddTrans: Boolean - 是否自动添加未翻译词句到多语言服务器, 默认为false
* callBack: Function - 初始化完成的回调函数

#### 代码示例

	// 在应用的主类初始化函数加入下面代码, 其中目标语言, 直接从行云传递给应用的flashVars里取得
	ML.init("ml_test", "cn", "en", "apiKey", onMLReady);
	function onMLReady():void
	{
		trace("ML Ready") ;
		trace(ML.trans("多语言服务测试")) ; // Multi-language service test
		trace(ML.transUrl("http://elex_p_img337-f.akamaihd.net/static/swf/ml-test/ml_swf_test.swf")) ;
		// http://f.xingcloud.com/ml-test/en/elex_p_img337-f.akamaihd.net/static/swf/ml-test/ml_swf_test.swf?md5=dff1c5ad2ce79ab8f86c2c82346b9c8a
	}

翻译词句：trans()
-----------------

public static function trans(source:String):String

通过该方法直接翻译词句。

#### 参数类型

* source: String - 需要翻译的词句, 如 "游戏开始"

#### 返回值

String - 翻译好的词句, 如 "game start"

#### 代码示例

	// 目标语言, 如"en", 直接从行云传递给应用的flashVars里取得
	ML.init("ml_test", "cn", "en", "apiKey", onMLReady);
	function onMLReady():void
	{
		startButton.text = ML.trans("游戏开始") ; // game start
		// your other code...
	}

语言资源地址转换：transUrl()
-----------------

public static function transUrl(sourceUrl:String):String

通过原始语言资源地址获取目标语言地址。 

#### 参数类型

* sourceUrl: String - 原始语言资源地址

#### 返回值

String - 目标语言资源地址

#### 代码示例

	// 目标语言, 如"en", 直接从行云传递给应用的flashVars里取得
	ML.init("ml_test", "cn", "en", "apiKey", onMLReady);
	function onMLReady():void
	{
		var cnSourceUrl:String = "http://elex_p_img337-f.akamaihd.net/static/swf/ml-test/ml_swf_test.swf" ;
		var enSourceUrl:String = ML.transUrl(cnSourceUrl) ;
		// http://f.xingcloud.com/ml-test/en/elex_p_img337-f.akamaihd.net/static/swf/ml-test/ml_swf_test.swf?md5=dff1c5ad2ce79ab8f86c2c82346b9c8a
	}
