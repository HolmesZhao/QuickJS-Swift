// QuickJS Swift
//
// Copyright (c) 2021 zqqf16
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import QuickJSC

public var QuickJSPath: String?

func js_module_loader_swift(_ ctx: OpaquePointer!, _ module_name: UnsafePointer<CChar>!, _ opaque: UnsafeMutableRawPointer!) -> OpaquePointer! {
    if let module_name,
       let name = String(cString: module_name, encoding: .utf8),
       let QuickJSPath {
        let moduleName = (QuickJSPath + name).withCString { $0 }
        return js_module_loader(ctx, moduleName, opaque)
    }
    return js_module_loader(ctx, module_name, opaque)
}

public class JSRuntime {
    public var jsInstance: OpaquePointer
    
    static let contextBuilder: @convention(c) (OpaquePointer?) -> OpaquePointer? = { rt in
        guard let ctx = JS_NewContext(rt) else {
            return nil
        }
        
        let _ = js_init_module_std(ctx, "std")
        let _ = js_init_module_std(ctx, "os")
        js_std_add_helpers(ctx, -1, nil)

        return ctx
    }
    
    public init?() {
        guard let runtime = JS_NewRuntime() else {
            return nil
        }
        self.jsInstance = runtime
        js_std_set_worker_new_context_func(JSRuntime.contextBuilder);
        js_std_init_handlers(runtime);
        JS_SetModuleLoaderFunc(runtime, nil, js_module_loader_swift, nil);
    }
    
    deinit {
        JS_FreeRuntime(self.jsInstance)
    }
    
    public func createContext() -> JSContext? {
        if let context = JSRuntime.contextBuilder(self.jsInstance) {
            return JSContext(self, context: context)
        }
        return nil
    }
}
