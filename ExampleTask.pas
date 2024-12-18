unit ExampleTask;

interface

uses System.SysUtils, AbortableTask.Types;

type
  TExampleTask = class(TInterfacedObject, IAbortableTask<Integer, Integer>)
  strict private
    fKey: Integer;
    fMax: Integer;
    fProgressIndicator: IAbortableProgressIndicator<Integer>;
    function GetTaskName: string;
    procedure ExchangeProgressIndicator(out aTaskProgressIndicator: IAbortableProgressIndicator<Integer>;
      const aThreadProgressIndicator: IAbortableProgressIndicator<Integer>);
    function ExecuteTask: Integer;
    function GetResultForOccurredException(const aException: Exception): Integer;
    function GetResultForAbort(const aException: Exception): Integer;
  public
    constructor Create(const aKey: Integer; const aProgressIndicator: IAbortableProgressIndicator<Integer>);
  end;

implementation

uses System.Classes, System.IOUtils;

{ TExampleTask }

constructor TExampleTask.Create(const aKey: Integer; const aProgressIndicator: IAbortableProgressIndicator<Integer>);
begin
  inherited Create;
  fKey := aKey;
  fProgressIndicator := aProgressIndicator;
  Randomize;
  fMax := Random(200) + 20;
end;

procedure TExampleTask.ExchangeProgressIndicator(out aTaskProgressIndicator: IAbortableProgressIndicator<Integer>;
  const aThreadProgressIndicator: IAbortableProgressIndicator<Integer>);
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
      lWriter.Write('Begin > ' + FormatDateTime('hh:nn:ss:zzz', Now)  + sLineBreak);
      fProgressIndicator.ProgressBegin(fKey, fMax);
      for var i := 1 to fMax do
      begin
        fProgressIndicator.ProgressStep(fKey, i);
        lWriter.Write(IntToStr(i) + ' > ' + FormatDateTime('hh:nn:ss:zzz', Now)  + sLineBreak);
        Sleep(Random(900) + 100);
      end;
    finally
      fProgressIndicator.ProgressEnd(fKey);
      lWriter.Write('End > ' + FormatDateTime('hh:nn:ss:zzz', Now)  + sLineBreak);
      lWriter.Free;
    end;
  finally
    lStream.Free;
  end;
  Result := fKey;
end;

function TExampleTask.GetResultForAbort(const aException: Exception): Integer;
begin
  Result := -1;
end;

function TExampleTask.GetResultForOccurredException(const aException: Exception): Integer;
begin
  Result := -2;
end;

function TExampleTask.GetTaskName: string;
begin
  Result := ClassName + ' ' + IntToStr(fKey);
end;

end.
