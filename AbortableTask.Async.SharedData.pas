unit AbortableTask.Async.SharedData;

interface

uses System.SysUtils, System.SyncObjs, AbortableTask.Types;

type
  TAbortableTaskAsyncSharedData<T> = class(TInterfacedObject, IAbortableTaskAsyncSharedData<T>)
  strict private
    fCritialSection: TCriticalSection;
    fAbortRequested: Boolean;
    fTaskResult: T;
    fFinishedState: TAbortableTaskFinishedState;
    fExceptionMessage: string;
    fExceptionClass: TClass;
    function GetExceptionMessage: string;
    function GetExceptionClass: TClass;
    function GetAbortRequested: Boolean;
    function GetTaskResult: T;
    function GetFinishedState: TAbortableTaskFinishedState;
    procedure RequestAbort;
    procedure SetSucceededState(const aTaskResult: T);
    procedure SetAbortedState(const aException: Exception; const aTaskResult: T);
    procedure SetExceptedState(const aException: Exception; const aTaskResult: T);
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TAbortableTaskAsyncSharedData<T> }

constructor TAbortableTaskAsyncSharedData<T>.Create;
begin
  inherited Create;
  fCritialSection := TCriticalSection.Create;
end;

destructor TAbortableTaskAsyncSharedData<T>.Destroy;
begin
  fCritialSection.Free;
  inherited;
end;

function TAbortableTaskAsyncSharedData<T>.GetFinishedState: TAbortableTaskFinishedState;
begin
  fCritialSection.Enter;
  try
    Result := fFinishedState;
  finally
    fCritialSection.Leave;
  end;
end;

function TAbortableTaskAsyncSharedData<T>.GetTaskResult: T;
begin
  fCritialSection.Enter;
  try
    Result := fTaskResult;
  finally
    fCritialSection.Leave;
  end;
end;

function TAbortableTaskAsyncSharedData<T>.GetAbortRequested: Boolean;
begin
  fCritialSection.Enter;
  try
    Result := fAbortRequested;
  finally
    fCritialSection.Leave;
  end;
end;

function TAbortableTaskAsyncSharedData<T>.GetExceptionClass: TClass;
begin
  fCritialSection.Enter;
  try
    Result := fExceptionClass;
  finally
    fCritialSection.Leave;
  end;
end;

function TAbortableTaskAsyncSharedData<T>.GetExceptionMessage: string;
begin
  fCritialSection.Enter;
  try
    Result := fExceptionMessage;
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAbortableTaskAsyncSharedData<T>.RequestAbort;
begin
  fCritialSection.Enter;
  try
    fAbortRequested := True;
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAbortableTaskAsyncSharedData<T>.SetSucceededState(const aTaskResult: T);
begin
  fCritialSection.Enter;
  try
    fTaskResult := aTaskResult;
    fFinishedState := TAbortableTaskFinishedState.Succeeded;
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAbortableTaskAsyncSharedData<T>.SetAbortedState(const aException: Exception; const aTaskResult: T);
begin
  fCritialSection.Enter;
  try
    fTaskResult := aTaskResult;
    fExceptionMessage := aException.Message;
    fExceptionClass := aException.ClassType;
    fFinishedState := TAbortableTaskFinishedState.Aborted;
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAbortableTaskAsyncSharedData<T>.SetExceptedState(const aException: Exception; const aTaskResult: T);
begin
  fCritialSection.Enter;
  try
    fTaskResult := aTaskResult;
    fExceptionMessage := aException.Message;
    fExceptionClass := aException.ClassType;
    fFinishedState := TAbortableTaskFinishedState.Excepted;
  finally
    fCritialSection.Leave;
  end;
end;

end.
