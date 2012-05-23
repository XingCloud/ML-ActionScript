XingCloud Multi-Language Service
=============

Overview
--------------
行云多语言服务（简称ML）集成三大功能：
1.多语言翻译 
2.全球静态资源CDN加速
3.版本控制
于一体进行管理，做到游戏资源的多语言处理流程简单透明，为应用全球一体化打下坚实基础。


初始化：ML.init()
--------------
public static function init(serviceName:String，lang:String，apiKey:String，callBack:Function):void

通过该方法初始化ML。初始化后即可通过ML.trans()翻译词句、通过ML.transUrl()获取目标语言CDN地址。
需要先登陆行云管理系统创建多语言服务 http://p.xingcloud.com

#### 参数类型

* serviceName: String - 服务名称，如 "bddemo"
* apiKey: String - 行云多语言管理系统分配的API密钥，如 "7e77da37d4bdf68bdadc107c27b01672"
* sourceLang: String - 原始语言，如"cn"
* targetLang: String - 目标语言，如"en", 直接从行云传递给应用的flashVars里取得
* callBack: Function - 初始化完成的回调函数

#### 代码示例

	// 在应用的主类初始化函数加入下面一行代码，其中目标语言，应直接从行云传递给应用的flashVars里取得
	ML.init("bddemo", "7e77da37d4bdf68bdadc107c27b01672", "cn", "en", onMLReady) ;
	
	// 申明一个方法onMLReady，ML初始化完成的回自动调用该方法，应用本身的初始化应从这个方法开始
	private function onMLReady():void
	{
		trace(ML.transUrl("url")) ;
		gameInit(); // 应用自己的初始化方法
	}

翻译词句：trans()
-----------------

public static function trans(source:String):String

使用本接口直接获取词句的翻译，需要初始化前配置 ML.useTrans = true; 示例如 ML.trans("世界你好");

#### 参数类型

* source: String - 需要翻译的词句，如 "世界你好"

#### 返回值

* String - 翻译好的词句，如 "hello world"

#### 代码示例

	ML.init("bddemo", "7e77da37d4bdf68bdadc107c27b01672", "cn", "en", onMLReady) ;
	private function onMLReady():void
	{
		aButton.text = ML.trans("世界你好") ; // hello world
		// your other code...
	}

语言资源地址转换：transUrl()
-----------------

public static function transUrl(sourceUrl:String):String

通过原始语言地址获取目标语言地址。强烈建议使用该方法处理应用中的多语言资源请求，优势如下：
<li>直接通过初始化配置的目标语言获取地址，代码逻辑与语言无关</li>
<li>目标语言地址携带资源文件MD5，享受CDN加速而无需担心缓存</li>

#### 参数类型

* sourceUrl: String - 原始语言资源地址

#### 返回值

String - 目标语言资源地址

#### 代码示例

	ML.init("bddemo", "7e77da37d4bdf68bdadc107c27b01672", "cn", "en", onMLReady) ;
	private function onMLReady():void
	{
		var cnSourceUrl:String = "http://elex_p_img337-f.akamaihd.net/static/swf/ml-test/ml_swf_test.swf" ;
		var enSourceUrl:String = ML.transUrl(cnSourceUrl) ;
	}