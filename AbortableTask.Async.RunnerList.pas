unit AbortableTask.Async.RunnerList;

interface

uses System.Classes, System.SysUtils, System.Generics.Collections, System.SyncObjs, AbortableTask.Types;

type
  TAbortableTaskAsyncRunnerList = class(TInterfacedObject, IAbortableTaskAsyncRunnerList)
  strict private
    fCritialSection: TCriticalSection;
    fList: TList<IAbortableTaskAsyncRunnerBase>;
    fRequestAbortToAllEvent: TLightweightEvent;
    procedure Add(const aRunner: IAbortableTaskAsyncRunnerBase);
    procedure Remove(const aRunner: IAbortableTaskAsyncRunnerBase);
    function GetCount: Integer;
    function First: IAbortableTaskAsyncRunnerBase;
    procedure RequestAbortToAllAndWait;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses Helper.Async;

{ TAbortableTaskAsyncRunnerList }

constructor TAbortableTaskAsyncRunnerList.Create;
begin
  inherited Create;
  fCritialSection := TCriticalSection.Create;
  fRequestAbortToAllEvent := TLightweightEvent.Create;
  fList := TList<IAbortableTaskAsyncRunnerBase>.Create;
end;

destructor TAbortableTaskAsyncRunnerList.Destroy;
begin
  fList.Free;
  fRequestAbortToAllEvent.Free;
  fCritialSection.Free;
  inherited;
end;

function TAbortableTaskAsyncRunnerList.First: IAbortableTaskAsyncRunnerBase;
begin
  fCritialSection.Enter;
  try
    Result := fList.First;
  finally
    fCritialSection.Leave;
  end;
end;

function TAbortableTaskAsyncRunnerList.GetCount: Integer;
begin
  fCritialSection.Enter;
  try
    Result := fList.Count;
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAbortableTaskAsyncRunnerList.Add(const aRunner: IAbortableTaskAsyncRunnerBase);
begin
  if fRequestAbortToAllEvent.IsSet then
    Exit;

  fCritialSection.Enter;
  try
    if not fList.Contains(aRunner) then
      fList.Add(aRunner);
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAbortableTaskAsyncRunnerList.Remove(const aRunner: IAbortableTaskAsyncRunnerBase);
begin
  if fRequestAbortToAllEvent.IsSet then
    Exit;

  fCritialSection.Enter;
  try
    fList.Remove(aRunner);
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAbortableTaskAsyncRunnerList.RequestAbortToAllAndWait;
var
  lWaitObjects: TArray<THandle>;
  i: Integer;
  lRunner: IAbortableTaskAsyncRunnerBase;
begin
  fRequestAbortToAllEvent.SetEvent;
  try
    fCritialSection.Enter;
    try
      SetLength(lWaitObjects, fList.Count);
      i := 0;
      for lRunner in fList do
      begin
        lWaitObjects[i] := lRunner.WorkerThreadHandle;
        Inc(i);
        lRunner.RequestAbort;
      end;
      WaitForWhileProcessMessages(lWaitObjects, TWaitForKind.WaitForAll);
      fList.Clear;
    finally
      fCritialSection.Leave;
    end;
  finally
    fRequestAbortToAllEvent.ResetEvent;
  end;
end;

end.
