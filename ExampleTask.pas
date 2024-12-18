unit ExampleTask;

interface

uses System.SysUtils, AbortableAsyncTask.Types;

type
  TExampleTask = class(TInterfacedObject, IAbortableAsyncTask<Integer, Integer>)
  strict private
    fKey: Integer;
    fProgressIndicator: IAbortableAsyncProgressIndicator<Integer>;
    function GetTaskName: string;
    procedure ExchangeProgressIndicator(out aTaskProgressIndicator: IAbortableAsyncProgressIndicator<Integer>;
      const aThreadProgressIndicator: IAbortableAsyncProgressIndicator<Integer>);
    function ExecuteTask: Integer;
    procedure ExceptionOccurred(const aException: Exception);
  public
    constructor Create(const aKey: Integer; const aProgressIndicator: IAbortableAsyncProgressIndicator<Integer>);
  end;

implementation

uses System.Classes, System.IOUtils;

{ TExampleTask }

constructor TExampleTask.Create(const aKey: Integer; const aProgressIndicator: IAbortableAsyncProgressIndicator<Integer>);
begin
  inherited Create;
  fKey := aKey;
  fProgressIndicator := aProgressIndicator;
end;

procedure TExampleTask.ExceptionOccurred(const aException: Exception);
begin

end;

procedure TExampleTask.ExchangeProgressIndicator(out aTaskProgressIndicator: IAbortableAsyncProgressIndicator<Integer>;
  const aThreadProgressIndicator: IAbortableAsyncProgressIndicator<Integer>);
begin
  aTaskProgressIndicator := fProgressIndicator;
  fProgressIndicator := aThreadProgressIndicator;
end;

function TExampleTask.ExecuteTask: Integer;
var lStream: TStream;
  lWriter: TTextWriter;
begin
  lStream := TFileStream.Create(TPath.Combine(ExtractFilePath(ParamStr(0)), 'ExampleTask' + IntToStr(fKey) + '.txt'),
    fmCreate or fmOpenWrite or fmShareDenyWrite);
  try
    lWriter := TStreamWriter.Create(lStream, TEncoding.UTF8);
    try
      const lMax = 20;
      lWriter.Write('Begin > ' + FormatDateTime('hh:nn:ss:zzz', Now)  + sLineBreak);
      fProgressIndicator.ProgressBegin(fKey, lMax);
      for var i := 1 to lMax do
      begin
        fProgressIndicator.ProgressStep(fKey, i);
        lWriter.Write(IntToStr(i) + ' > ' + FormatDateTime('hh:nn:ss:zzz', Now)  + sLineBreak);
        Sleep(1000);
      end;
    finally
      fProgressIndicator.ProgressEnd(fKey);
      lWriter.Write('End > ' + FormatDateTime('hh:nn:ss:zzz', Now)  + sLineBreak);
      lWriter.Free;
    end;
  finally
    lStream.Free;
  end;
  Result := 855;
end;

function TExampleTask.GetTaskName: string;
begin
  Result := ClassName;
end;

end.
