import Foundation
import Dispatch

public class Async {
    public init() {}
    private var canceled = false
    private var group = DispatchGroup()
    private var tasks:[AsyncTask] = []
    fileprivate func complete(){
        group.leave()
    }
    private func run(task:AsyncTask){
        group.enter()
        task.run()
    }
    public func cancel(){
        canceled = true
        self.tasks.forEach{$0.cancalTask()}
    }
    public func run(_ complete:@escaping (_ tasks:[AsyncTask]) -> Void) {
        tasks.forEach { task in
            self.run(task: task)
        }
        group.notify(queue: DispatchQueue.main){
            if self.canceled { return }
            complete(self.tasks)
        }
    }
    public func task(_ name:String = "") -> AsyncTask{
        let task = AsyncTask(self)
        task.taskName = name
        tasks.append(task)
        return task
    }
    
    
    public enum AsyncTaskState{
        case pending
        case complete(success:Bool)
    }
    
    public class AsyncTask{
        public var state:AsyncTaskState = .pending
        public var ud:[AnyHashable:Any] = [:]
        public var taskName:String = ""
        private weak var async:Async? = nil
        
        fileprivate init(_ async:Async) {
            self.async = async
        }
        var executeBlock:(_ task:AsyncTask) -> Void = {task in
            task.complete(success: false)
        }
        var cancelBlock:(_ task:AsyncTask) -> Void = {task in}
        fileprivate func run(){
            self.executeBlock(self)
        }
        public func complete(success:Bool){
            self.state = .complete(success: success)
            self.async?.complete()
        }
        fileprivate func cancalTask() {
            self.cancelBlock(self)
        }
        public func cancel(_ block:@escaping (_ task:AsyncTask) -> Void) -> AsyncTask{
            self.cancelBlock = block
            return self
        }
        public func execute(_ block:@escaping (_ task:AsyncTask) -> Void) -> AsyncTask{
            self.executeBlock = block
            return self
        }
    }
}
