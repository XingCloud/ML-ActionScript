[XingCloud](http://www.xingcloud.com) Multi-Language Service
==============

[行云多语言服务  ML](http://doc.xingcloud.com) 
--------------
行云多语言服务（简称ML）集成一键多语言翻译、自动全球静态资源[CDN](http://zh.wikipedia.org/wiki/CDN)同步、智能文件版本控制三大功能于一体。    
做到应用的多语言处理流程简单透明，只需一行代码，即可为您的应用启动全球一体化。
* 一键多语言翻译（一键翻译SWF、XML、JSON为22种语言） 
* 自动CDN加速（免去全球范围内的CDN洽谈、采购、同步上传等繁琐流程，一切自动完成）
* 智能文件版本控制（根据文件内容进行版本控制，智能精准）

一行代码使用行云多语言服务：ML.transUrl(sourceUrl)
--------------
使用 ML.transUrl(sourceUrl) 处理需要翻译的语言资源（XML或SWF）地址，即可享受行云多语言服务的三大功能。    
如加载一个中文的SWF，使用ML前为 loader.load(swfUrl) 使用ML后为 loader.load(ML.transUrl(swfUrl)) 简单完整示例如下：

#### 代码示例（完整）
__提示：在FlashBuilder中新建项目，导入ml.swc，新建MLTest.as，粘贴以下代码可直接编译执行。在[行云管理平台](http://p.xingcloud.com)可以创建自己的项目。__	
	
	package 
	{
		import com.xingcloud.ml.ML;
		import flash.display.Loader;
		import flash.net.URLRequest;
	
		public class MLTest extends flash.display.Sprite
		{
			public function MLTest()
			{
				// 在应用的主类构造方法中加入下面一行ML初始化代码
				ML.init("bddemo", "7e77da37d4bdf68bdadc107c27b01672", "cn", "en", onMLReady) ;
				// init方法参数依次为：服务名称，apiKey，原始语言，目标语言，回调方法（目标语言 应由参数控制，不要写死）
			}
			
			// 申明一个方法onMLReady，ML初始化完成会自动调用该方法，应从这里开始应用的初始化
			private function onMLReady():void
			{
				gameInit() ;
				// otherInit() ;
			}
			
			// 应用的初始化方法，演示加载SWF文件 ml_swf_test.swf
			private function gameInit():void
			{
				var loader:Loader = new Loader() ;
				var swfUrl:String = "http://173.230.133.116/xingcloud/ml_swf_test.swf" ;
				addchild(loader) ;
				
				// loader.load(new URLRequest(swfUrl)) ; // 使用ML之前的代码
				loader.load(new URLRequest(ML.transUrl(swfUrl))) ; // 使用ML之后的代码
				// 实际加载地址为 http://cdn.xingcloud.com/bddemo/cn/173.230.133.116/xingcloud/ml_swf_test.swf?xcv=01
			}
		}	
	}

翻译代码中的词句和链接：ML.trans(source)
-----------------
传入A返回B。A可以是一条词句或者链接。_使用该接口初始化前需配置 ML.useTrans = true;_
* A如果是词句，返回B为翻译后的词句。如 ML.trans("你好世界") 返回 "hello world" 
* A如果是链接，返回B是目标平台的对应链接。如 trans("国内平台粉丝墙链接") 返回 "facebook平台粉丝墙链接"  

__注意：不建议使用该接口翻译词句，以避免代码与语言耦合，语言应组织为语言包（XML文件）。__


#### 代码示例（片断）

	ML.useTrans = true ; // 初始化前配置
	ML.init("bddemo", "7e77da37d4bdf68bdadc107c27b01672", "cn", "en", onMLReady) ;
	private function onMLReady():void
	{
		aButton.text = ML.trans("世界你好") ; // hello world
		bbsUrl = "http://sobar.soso.com/b/3007483_1675" ; // 快乐征途的Qznoe论坛链接
		ML.trans(bbsUrl) ; // http://www.facebook.com/happymarch // 快乐征途的facebook粉丝墙链接
	}
	
	