unit Helper.Async;

interface

type
  TWaitForState = (Undefined, Signaled, Abandoned, Timeout, WaitFailed, NoWaitObjectsError, TooManyWaitObjectsError);

  TWaitForResult = record
    State: TWaitForState;
    LastError: Cardinal;
  end;

  TWaitForKind = (WaitForOne, WaitForAll);

function WaitForWhileProcessMessages(const aWaitObjects: TArray<THandle>;
  const aWaitForKind: TWaitForKind;
  const aTimeout: Cardinal): TWaitForResult; overload;

function WaitForWhileProcessMessages(const aWaitObjects: TArray<THandle>;
  const aWaitForKind: TWaitForKind): TWaitForResult; overload;

implementation

uses Winapi.Windows;

function WaitForWhileProcessMessages(const aWaitObjects: TArray<THandle>;
  const aWaitForKind: TWaitForKind): TWaitForResult;
begin
  Result := WaitForWhileProcessMessages(aWaitObjects, aWaitForKind, INFINITE);
end;

function WaitForWhileProcessMessages(const aWaitObjects: TArray<THandle>;
  const aWaitForKind: TWaitForKind;
  const aTimeout: Cardinal): TWaitForResult;
var
  lWaitObjects: TArray<THandle>;
  lWaitObjectsCount: Cardinal;
  lWaitForAll: Boolean;
  lWaitResult: Cardinal;
  lMsg: TMsg;
begin
  Result := default(TWaitForResult);
  lWaitObjects := aWaitObjects;
  lWaitObjectsCount := Length(lWaitObjects);

  if lWaitObjectsCount = 0 then
  begin
    Result.State := TWaitForState.NoWaitObjectsError;
    Exit;
  end;

  // -1 is correct here.
  // See https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-msgwaitformultipleobjects
  if lWaitObjectsCount > MAXIMUM_WAIT_OBJECTS - 1 then
  begin
    Result.State := TWaitForState.TooManyWaitObjectsError;
    Exit;
  end;

  lWaitForAll := aWaitForKind = TWaitForKind.WaitForAll;

  while True do
  begin
    lWaitResult := MsgWaitForMultipleObjects(lWaitObjectsCount, lWaitObjects[0], lWaitForAll, aTimeout, QS_ALLINPUT);
    if lWaitResult = WAIT_OBJECT_0 then
    begin
      // One or all wait objects are in signaled state.
      Result.State := TWaitForState.Signaled;
      Exit;
    end
    else if lWaitResult = WAIT_OBJECT_0 + lWaitObjectsCount then
    begin
      // Queued messages will be processed while waiting.
      while PeekMessage(lMsg, 0, 0, 0, PM_REMOVE) do
      begin
        DispatchMessage(lMsg);
      end;
    end
    else if lWaitResult = WAIT_ABANDONED_0 then
    begin
      // One or all wait objects are in abandoned state.
      Result.State := TWaitForState.Abandoned;
      Exit;
    end
    else if lWaitResult = WAIT_TIMEOUT then
    begin
      Result.State := TWaitForState.Timeout;
      Exit;
    end
    else if lWaitResult = WAIT_FAILED then
    begin
      Result.State := TWaitForState.WaitFailed;
      Result.LastError := GetLastError;
      Exit;
    end;
  end;
end;


end.
