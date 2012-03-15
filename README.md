ML AS SDK
=============

初始化：init()
--------------

static public function init(serviceName:String, lang:String, apiKey:String, callBack:Function=null):void

通过该方法初始化ML。初始化后即可通过ML.trans()翻译词句。

#### 参数类型

* serviceName: String - 服务名称, 如 "my_ml_test"
* apiKey: String - 行云多语言管理系统分配的API密钥, 如 "21f...e35"
* sourceLang: String - 原始语言, 如"cn"
* targetLang: String - 目标语言, 如"en", 如果与原始语言相同, 则不翻译直接原文返回
* autoAddTrans: Boolean - 是否自动添加未翻译词句到多语言服务器, 默认为false
* callBack: Function - 初始化完成的回调函数, 可为空

#### 返回值

N/A

#### 代码示例

	// 在应用的主类初始化函数中加入下面这行代码，如果与原始语言相同，则不翻译直接原文返回
	ML.init("ml_test", "cn", "en", "apiKey", onMLReady);
	function onMLReady():void
	{
		trace("ML Ready") ;
	}
	

翻译词句：trans()
-----------------

static public function trans(source:String):String

通过该方法直接翻译词句。

#### 参数类型

* source: String - 需要翻译的词句, 如 "游戏开始"

#### 返回值

String - 翻译好的词句, 如 "game start"

#### 代码示例

	// 示例
	ML.init("ml_test", "cn", "en", "apiKey", onMLReady);
	
	function onMLReady():void
	{
		startLabel.text = ML.trans("游戏开始") ;
		//your other code...
	}

语言资源地址转换：transUrl()
-----------------

static public function transUrl(sourceUrl:String):String

通过原始语言资源地址获取目标语言地址。 

#### 参数类型

* sourceUrl: String - 原始语言资源地址

#### 返回值

String - 目标语言资源地址

#### 代码示例

	// 示例
	ML.init("ml_test", "cn", "en", "apiKey", onMLReady);
	
	function onMLReady():void
	{
		var cnSourceUrl:String = "http://i am cn source url" ;
		var enSourceUrl:String = ML.transUrl(cnSourceUrl) ;
		//your other code...
	}
