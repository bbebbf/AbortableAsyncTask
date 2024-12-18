unit AbortableAsyncTask.Result;

interface

uses System.SysUtils, AbortableAsyncTask.Types;

type
  TAbortableAsyncTaskResultBase = class(TInterfacedObject, IAbortableAsyncTaskResultBase)
  strict private
    fFinishedState: TAbortableAsyncTaskTaskFinishedState;
    fExceptionMessage: string;
    fExceptionClass: TClass;
    function GetFinishedState: TAbortableAsyncTaskTaskFinishedState;
    function GetExceptionMessage: string;
    function GetExceptionClass: TClass;
  public
    constructor Create(const aFinishedState: TAbortableAsyncTaskTaskFinishedState;
      const aExceptionClass: TClass; const aExceptionMessage: string);
  end;

  TAbortableAsyncTaskResult<T> = class(TAbortableAsyncTaskResultBase, IAbortableAsyncTaskResult<T>)
  strict private
    fResult: T;
    function GetResult: T;
  public
    constructor Create(const aFinishedState: TAbortableAsyncTaskTaskFinishedState;
      const aExceptionClass: TClass; const aExceptionMessage: string; const aResult: T);
  end;

implementation

{ TAbortableAsyncTaskResultBase }

constructor TAbortableAsyncTaskResultBase.Create(const aFinishedState: TAbortableAsyncTaskTaskFinishedState;
  const aExceptionClass: TClass; const aExceptionMessage: string);
begin
  inherited Create;
  fFinishedState := aFinishedState;
  fExceptionMessage := aExceptionMessage;
  fExceptionClass := aExceptionClass;
end;

function TAbortableAsyncTaskResultBase.GetExceptionClass: TClass;
begin
  Result := fExceptionClass;
end;

function TAbortableAsyncTaskResultBase.GetExceptionMessage: string;
begin
  Result := fExceptionMessage;
end;

function TAbortableAsyncTaskResultBase.GetFinishedState: TAbortableAsyncTaskTaskFinishedState;
begin
  Result := fFinishedState;
end;

{ TAbortableAsyncTaskResult<T> }

constructor TAbortableAsyncTaskResult<T>.Create(const aFinishedState: TAbortableAsyncTaskTaskFinishedState;
  const aExceptionClass: TClass; const aExceptionMessage: string; const aResult: T);
begin
  inherited Create(aFinishedState, aExceptionClass, aExceptionMessage);
  fResult := aResult;
end;

function TAbortableAsyncTaskResult<T>.GetResult: T;
begin
  Result := fResult;
end;

end.
