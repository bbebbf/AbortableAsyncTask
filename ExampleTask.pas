unit ExampleTask;

interface

uses System.SysUtils, AbortableTask.Types, AbortableTaskApp.Types;

type
  TExampleTask = class(TInterfacedObject, IAbortableTask<Integer, Integer>)
  strict private
    fKey: Integer;
    fMax: Integer;
    fProgressIndicator: IAbortableTaskAppProgressIndicator<Integer>;
    fTaskProcessor: IAbortableTaskProcessor;

    function GetTaskName: string;
    procedure SetTaskProcessor(const aTaskProcessor: IAbortableTaskProcessor);
    function ExecuteTask: Integer;
    function GetResultForOccurredException(const aException: Exception): Integer;
    function GetResultForAbort(const aException: Exception): Integer;
  public
    constructor Create(const aKey: Integer; const aProgressIndicator: IAbortableTaskAppProgressIndicator<Integer>);
  end;

implementation

uses System.Classes, System.IOUtils;

{ TExampleTask }

constructor TExampleTask.Create(const aKey: Integer; const aProgressIndicator: IAbortableTaskAppProgressIndicator<Integer>);
begin
  inherited Create;
  fKey := aKey;
  fProgressIndicator := aProgressIndicator;
  Randomize;
  fMax := Random(200) + 20;
end;

procedure TExampleTask.SetTaskProcessor(const aTaskProcessor: IAbortableTaskProcessor);
begin
  fTaskProcessor := aTaskProcessor;
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

      fTaskProcessor.QueueMethod(
        procedure
        begin
          fProgressIndicator.ProgressBegin(fKey, fMax);
        end
      );

      for var i := 1 to fMax do
      begin
        fTaskProcessor.CheckForRequestAbort;

        fTaskProcessor.QueueMethod(
          procedure
          begin
            fProgressIndicator.ProgressStep(fKey, i);
          end
        );

        lWriter.Write(IntToStr(i) + ' > ' + FormatDateTime('hh:nn:ss:zzz', Now)  + sLineBreak);
        Sleep(Random(900) + 100);
      end;
    finally
      fTaskProcessor.QueueMethod(
        procedure
        begin
          fProgressIndicator.ProgressEnd(fKey);
        end
      );

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
