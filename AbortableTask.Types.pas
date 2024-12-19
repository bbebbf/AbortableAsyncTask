unit AbortableTask.Types;

interface

uses System.Classes, System.SysUtils, Helper.Async;

type
  TQueueableMethod = reference to procedure;

  IAbortableTaskProcessor = interface
    ['{3AFC9542-14E5-45D0-94BE-DF950DBC659A}']
    procedure QueueMethod(const aQueueableMethod: TQueueableMethod);
    procedure CheckForRequestAbort;
  end;

  IAbortableTask<T, K> = interface
    ['{E3702C3E-51AD-4EB7-9FB8-E816C039163F}']
    function GetTaskName: string;
    procedure SetTaskProcessor(const aTaskProcessor: IAbortableTaskProcessor);
    function GetResultForOccurredException(const aException: Exception): T;
    function GetResultForAbort(const aException: Exception): T;
    function ExecuteTask: T;
  end;

  TAbortableTaskFinishedState = (Unknown, Succeeded, Aborted, Excepted, WaitForError);

  IAbortableTaskResultBase = interface
    ['{E292DE06-D067-4795-8274-2B299C189DF1}']
    function GetFinishedState: TAbortableTaskFinishedState;
    function GetExceptionMessage: string;
    function GetExceptionClass: TClass;

    property FinishedState: TAbortableTaskFinishedState read GetFinishedState;
    property ExceptionMessage: string read GetExceptionMessage;
    property ExceptionClass: TClass read GetExceptionClass;
  end;

  IAbortableTaskResult<T> = interface(IAbortableTaskResultBase)
    ['{CDF7CFF2-AAD8-48A1-A570-89060D31BD87}']
    function GetResult: T;
    property &Result: T read GetResult;
  end;

  IAbortableTaskAsyncRunnerBase = interface
    ['{C7817F76-53F6-4D41-BBEB-9663AC4DB3BD}']
    function IsRunning: Boolean;
    procedure RequestAbort;
    function WaitForTask: IAbortableTaskResultBase;
    function GetWorkerThreadHandle: THandle;

    property WorkerThreadHandle: THandle read GetWorkerThreadHandle;
  end;

  IAbortableTaskAsyncRunner<T> = interface(IAbortableTaskAsyncRunnerBase)
    ['{65763F41-A120-4B42-8FB5-472D594956E8}']
    function WaitForTaskResult: IAbortableTaskResult<T>;
  end;

  IAbortableTaskAsyncRunnerList = interface
    ['{BB2609C0-A2EB-4D1E-B6DE-65EF877F84B5}']
    procedure Add(const aRunner: IAbortableTaskAsyncRunnerBase);
    procedure Remove(const aRunner: IAbortableTaskAsyncRunnerBase);
    function GetCount: Integer;
    function First: IAbortableTaskAsyncRunnerBase;
    procedure RequestAbortToAllAndWait;
    property Count: Integer read GetCount;
  end;

  IAbortableTaskAsyncSharedData<T> = interface
    ['{885D45BF-03D1-4732-B851-B34EC3EAB18A}']
    function GetExceptionMessage: string;
    function GetExceptionClass: TClass;
    function GetAbortRequested: Boolean;
    procedure RequestAbort;
    procedure SetSucceededState(const aTaskResult: T);
    procedure SetAbortedState(const aException: Exception; const aTaskResult: T);
    procedure SetExceptedState(const aException: Exception; const aTaskResult: T);
    function GetTaskResult: T;
    function GetFinishedState: TAbortableTaskFinishedState;
    property AbortRequested: Boolean read GetAbortRequested;
    property FinishedState: TAbortableTaskFinishedState read GetFinishedState;
    property TaskResult: T read GetTaskResult;
    property ExceptionMessage: string read GetExceptionMessage;
    property ExceptionClass: TClass read GetExceptionClass;
  end;

  EAbortableAsyncTaskAbort = class(EAbort);

implementation

end.
