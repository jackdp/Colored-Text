unit CLT.App;

{$IFDEF FPC}
  {$mode delphi}
{$ENDIF}


interface

uses
  SysUtils,
  JPL.Console, JPL.Console.ColorParser, JPL.ConsoleApp, JPL.CmdLineParser, JPL.TStr,
  CLT.Types;

type


  TApp = class(TJPConsoleApp)
  private
    AppParams: TAppParams;
    FDefaultHighlightColors: string;
  public
    procedure Init;
    procedure Run;

    procedure RegisterOptions;
    procedure ProcessOptions;

    procedure PerformMainAction;

    procedure DisplayHelpAndExit(const ExCode: integer);
    procedure DisplayShortUsageAndExit(const Msg: string; const ExCode: integer);
    procedure DisplayBannerAndExit(const ExCode: integer);
    procedure DisplayMessageAndExit(const Msg: string; const ExCode: integer);
    procedure DisplayExamplesAndExit(const ExCode: integer);

    property DefaultHighlightColors: string read FDefaultHighlightColors;
  end;



implementation





{$region '                    Init                              '}

procedure TApp.Init;
const
  SEP_LINE = '-------------------------------------------------';
begin
  //----------------------------------------------------------------------------

  AppName := 'Colored Text';
  MajorVersion := 1;
  MinorVersion := 0;
  Self.Date := EncodeDate(2020, 10, 16);
  FullNameFormat := '%AppName% %MajorVersion%.%MinorVersion% [%OSShort% %Bits%-bit] (%AppDate%)';
  Description :=
    'Displays the <color=cyan>TEXT</color> specified on the command line (or redirected through a pipe) in the given colors. ' +
    'Optionally, it also highlights the given <color=yellow,black>substrings</color> in the input <color=cyan,black>TEXT</color>.';
  Author := 'Jacek Pazera';
  HomePage := 'https://www.pazera-software.com/products/colored-text/';
  HelpPage := HomePage;

  AppParams.GithubUrl := 'https://github.com/jackdp/Colored-Text';
  LicenseName := 'Freeware, Open Source';
  License := 'This program is completely free. You can use it without any restrictions, also for commercial purposes.' + ENDL +
    'The program''s source files are available at ' + AppParams.GithubUrl + ENDL +
    'Compiled binaries can be downloaded from ' + HomePage;

  TrimExtFromExeShortName := True;

  AppParams.Text := '';
  AppParams.SplitStr := '';
  AppParams.AddLogHighlights := True;
  AppParams.TextColor := TConsole.clNone;
  AppParams.BackgroundColor := TConsole.clNone;
  AppParams.AddEndlAtEnd := False;


  HintBackgroundColor := TConsole.clLightGrayBg;
  HintTextColor := TConsole.clBlackText;
  FDefaultHighlightColors := 'White,DarkMagenta';

  //-----------------------------------------------------------------------------

  TryHelpStr := ENDL + 'Try <color=white,black>' + ExeShortName + ' --help</color> for more information.';

  ShortUsageStr :=
    ENDL +
    'Usage: ' + ExeShortName +
    ' <color=cyan>TEXT</color> [-c=COLORS] [-n=STR] [-nn] [-ht=<color=yellow>STR</color>] [-hc=COLORS] [-s=1|0] [-l] [-h] [-V] [--license] ' +
    '[--github] [--home]' + ENDL +
    ENDL +
    'Mandatory arguments to short options are mandatory for long options too.' + ENDL +
    'Options are case-sensitive. Options and values in square brackets are optional.' + ENDL +
    'You can use the <color=white,black>-ht</color>, <color=white,black>-hc</color>, and <color=white,black>-s</color> options multiple times.';



  ExtraInfoStr :=
    SEP_LINE + ENDL +
    '<color=cyan,black>TEXT</color>' + ENDL +
    'Text can be given on the command line or/and redirected from an external command via a pipe.' + ENDL +
    'You can provide multiple text values in any combination with the options.' + ENDL +

    SEP_LINE + ENDL +
    'AVAILABLE COLORS' + ENDL +
    '  <color=none,    Red>  </color> Red, LightRed            <color=none,DarkRed>  </color> DarkRed' + ENDL +
    '  <color=none,  Green>  </color> Green, LightGreen        <color=none,DarkGreen>  </color> DarkGreen' + ENDL +
    '  <color=none,   Blue>  </color> Blue, LightBlue          <color=none,DarkBlue>  </color> DarkBlue' + ENDL +
    '  <color=none,   Cyan>  </color> Cyan, LightCyan          <color=none,DarkCyan>  </color> DarkCyan' + ENDL +
    '  <color=none,Magenta>  </color> Magenta, LightMagenta    <color=none,DarkMagenta>  </color> DarkMagenta' + ENDL +
    '  <color=none, Yellow>  </color> Yellow, LightYellow      <color=none,DarkYellow>  </color> DarkYellow' + ENDL +
    '  <color=none,   Gray>  </color> Gray, LightGray          <color=none,DarkGray>  </color> DarkGray' + ENDL +
    '  <color=none,  White>  </color> White                    <color=none,Black>  </color> Black' + ENDL +
    '  Fuchsia = LightMagenta, Purple = DarkMagenta' + ENDL +
    '  Lime = LightGreen, Aqua = LightCyan' + ENDl +
    'Color names are case insensitive.' +

    ENDL + SEP_LINE + ENDL +
    'EXIT CODES' + ENDL +
    '  ' + CON_EXIT_CODE_OK.ToString + ' - OK - no errors.' + ENDL +
    '  ' + CON_EXIT_CODE_SYNTAX_ERROR.ToString + ' - Syntax error.' + ENDL +
    '  ' + CON_EXIT_CODE_ERROR.ToString + ' - Other error.';

  ExamplesStr :=
    'EXAMPLES' + ENDL + ENDL +
    '  <color=white,black>Example 1</color>' + ENDL + '  Display the text "Lorem ipsum" in yellow:' + ENDL +
    '    ' + ExeShortName + ' "Lorem ipsum" -c yellow' + ENDL +
    '  Result:' + ENDL +
    '    <color=yellow>Lorem ipsum</color>' + ENDL + ENDL +

    '  <color=white,black>Example 2</color>' + ENDL + '  Display "Lorem ipsum" in white on a dark blue background:' + ENDL +
    '    ' + ExeShortName + ' "Lorem ipsum" -c White,DarkBlue' + ENDL +
    '  Result:' + ENDL +
    '    <color=white,darkblue>Lorem ipsum</color>' + ENDL + ENDL +

    '  <color=white,black>Example 3</color>' + ENDL +
    '  Display "Lorem ipsum dolor" in white on a dark blue background.' + ENDL +
    '  Highlight the letter "m" with the default color and highlight the text "lo" with yellow:' + ENDL +
    '    ' + ExeShortName + ' "Lorem ipsum dolor" -c White,DarkBlue -ht m -hc black,yellow -ht lo' + ENDL +
    '  Result:' + ENDL +
    '    <color=black,yellow>Lo</color><color=White,DarkBlue>re</color><color=' + DefaultHighlightColors + '>m</color>' +
    '<color=White,DarkBlue> ipsu</color><color=' + DefaultHighlightColors + '>m</color><color=White,DarkBlue> do</color>' +
    '<color=black,yellow>lo</color><color=White,DarkBlue>r</color>' + ENDL + ENDL +

    '  <color=white,black>Example 4</color>' + ENDL +
    '  Display the word "Lorem" in red, "ipsum" in green, and "dolor" in blue:' + ENDL +
    '    ' + ExeShortName + ' "Lorem" -c red & ' + ExeShortName + ' " ipsum" -c green & ' + ExeShortName + ' " dolor" -c blue' + ENDL +
    '  Result:' + ENDL +
    '    <color=red>Lorem</color> <color=green>ipsum</color> <color=blue>dolor</color>';

  //------------------------------------------------------------------------------


end;
{$endregion Init}


{$region '                    Run                               '}
procedure TApp.Run;
begin
  inherited;

  RegisterOptions;
  Cmd.Parse;
  ProcessOptions;
  if Terminated then Exit;

  PerformMainAction; // <----- the main procedure
end;
{$endregion Run}


{$region '                    RegisterOptions                   '}
procedure TApp.RegisterOptions;
const
  MAX_LINE_LEN = 110;
var
  Category: string;
begin

  Cmd.CommandLineParsingMode := cpmCustom;
  Cmd.UsageFormat := cufWget;
  Cmd.AcceptAllNonOptions := True; // All non-option params will be treated as the input text


  // ------------ Registering command-line options -----------------

  Category := 'info';

  Cmd.RegisterOption('c', 'colors', cvtRequired, False, False,
    'The foreground and background color of the TEXT specified on the command line. See the list of available colors below.',
    'FgColor[,BgColor]', Category);

  Cmd.RegisterOption('n', 'new-line', cvtRequired, False, False, 'Replace the STR with a newline character in the input text.', 'STR', Category);

  Cmd.RegisterShortOption('nn', cvtNone, False, False, 'Add a newline character at the end of the input text.', '', Category);

  Cmd.RegisterOption('ht', 'highlight-text', cvtRequired, False, False, 'Text to be highlighted.', 'STR', Category);

  Cmd.RegisterOption('hc', 'highlight-colors', cvtRequired, False, False,
    'The foreground and background color used to highlight the text specified with the "-ht" option. See the list of available colors below.',
    'FgColor[,BgColor]', Category);

  Cmd.RegisterOption('s', 'case-sensitive', cvtRequired, False, False,
    'Consider the character case when searching for the text to highlight. By default -s=0 (not case sensitive).', '1|0', Category);

  Cmd.RegisterOption('l', 'log-colors', cvtNone, False, False,
    'Highlight some special words used in the logs such as Error, Failed, Warning, Success etc.', '', Category);

  Cmd.RegisterOption('h', 'help', cvtNone, False, False, 'Show this help.', '', Category);
  Cmd.RegisterShortOption('?', cvtNone, False, True, '', '', '');
  Cmd.RegisterLongOption('examples', cvtNone, False, False, 'Display examples.', '', Category);
  Cmd.RegisterOption('V', 'version', cvtNone, False, False, 'Show application version.', '', Category);
  Cmd.RegisterLongOption('license', cvtNone, False, False, 'Display program license.', '', Category);
  Cmd.RegisterLongOption('home', cvtNone, False, False, 'Opens program home page in the default browser.', '', Category);
  Cmd.RegisterLongOption('github', cvtNone, False, False, 'Opens the GitHub page with the program''s source files.', '', Category);

  UsageStr :=
    ENDL +
    'OPTIONS' + ENDL + Cmd.OptionsUsageStr('  ', 'info', MAX_LINE_LEN, '   ', 30);

end;
{$endregion RegisterOptions}


{$region '                    ProcessOptions                    '}
procedure TApp.ProcessOptions;
var
  i: integer;
  s: string;
begin

  // ---------------------------- Invalid options -----------------------------------

  if Cmd.ErrorCount > 0 then
  begin
    DisplayShortUsageAndExit(Cmd.ErrorsStr, TConsole.ExitCodeSyntaxError);
    Exit;
  end;


  // ---------------------------- Log colors -----------------------------------

  AppParams.AddLogHighlights := Cmd.IsOptionExists('log-colors');


  // ----------------------------- ENDL at the end ------------------------

  AppParams.AddEndlAtEnd := Cmd.IsShortOptionExists('nn');


  // ----------- Input redirected from the external command with the pipe -------------

  if TConsole.IsInputRedirected then
  while not EOF do
  begin
    Readln(s);
    AppParams.Text += s + ENDL;
  end;


  //------------------------------------ Help ---------------------------------------

  if (ParamCount = 0) or (Cmd.IsLongOptionExists('help')) or (Cmd.IsOptionExists('?')) then
  begin
    DisplayHelpAndExit(TConsole.ExitCodeOK);
    Exit;
  end;


  //---------------------------------- Home -----------------------------------------

  {$IFDEF MSWINDOWS}
  if Cmd.IsLongOptionExists('home') then
  begin
    GoToHomePage;
    Terminate;
    Exit;
  end;

  if Cmd.IsOptionExists('github') then
  begin
    GoToUrl(AppParams.GithubUrl);
    Terminate;
    Exit;
  end;
  {$ENDIF}


  //------------------------------- Version ------------------------------------------

  if Cmd.IsOptionExists('version') then
  begin
    DisplayMessageAndExit(AppFullName, TConsole.ExitCodeOK);
    Exit;
  end;


  //------------------------------- Version ------------------------------------------

  if Cmd.IsLongOptionExists('license') then
  begin
    TConsole.WriteTaggedTextLine('<color=white,black>' + LicenseName + '</color>');
    DisplayLicense;
    Terminate;
    Exit;
  end;

  // ------------------------ Examples ---------------------------

  if Cmd.IsLongOptionExists('examples') then
  begin
    DisplayExamplesAndExit(TConsole.ExitCodeOK);
    Exit;
  end;


  // ------------------- Colors: Text & Background ----------------------

  if Cmd.IsOptionExists('c') then
  begin
    s := Cmd.GetOptionValue('c', '');
    ConGetColorsFromStr(s, AppParams.TextColor, AppParams.BackgroundColor);
  end;


  // -------------- SplitStr ------------

  if Cmd.IsOptionExists('n') then AppParams.SplitStr := Cmd.GetOptionValue('n');


  //---------------------------- Unknown Params --------------------------
  for i := 0 to Cmd.UnknownParamCount - 1 do
    AppParams.Text += StripQuotes(Cmd.UnknownParams[i].ParamStr);


  if AppParams.Text = '' then
  begin
    DisplayError('No input text was provided!');
    ExitCode := TConsole.ExitCodeError;
    Terminate;
    Exit;
  end;


end;

{$endregion ProcessOptions}




{$region '                    PerformMainAction                     '}
procedure TApp.PerformMainAction;
type
  TTextColorsRec = record
    Text: string;
    Colors: string;
    csMode: TConParCaseSensitiveMode;
  end;
var
  cc: TConColorParser;
  Param: TClpParam;
  i: integer;
  CurrentHighlightColors, OptName: string;
  Arr: array of TTextColorsRec;
  CSMode: TConParCaseSensitiveMode;

  procedure AddToArray(const s, ColorsStr: string; Mode: TConParCaseSensitiveMode);
  begin
    SetLength(Arr, Length(Arr) + 1);
    Arr[High(Arr)].Text := s;
    Arr[High(Arr)].Colors := ColorsStr;
    Arr[High(Arr)].csMode := Mode;
  end;
begin
  if Terminated then Exit;
  if AppParams.Text = '' then Exit;

  if AppParams.AddLogHighlights then
  begin
    AddToArray('Error', 'White,LightRed', csmIgnoreCase);
    AddToArray('Failed', 'Red,Black', csmIgnoreCase);
    AddToArray('Fail', 'Red,Black', csmIgnoreCase);
    AddToArray('cannot', 'LightMagenta,Black', csmIgnoreCase);
    AddToArray('can''t', 'LightMagenta,Black', csmIgnoreCase);
    AddToArray('not found', 'LightMagenta,Black', csmIgnoreCase);
    AddToArray('Warning', 'LightYellow,Black', csmIgnoreCase);
    AddToArray('Success', 'LightGreen,Black', csmIgnoreCase);
  end;


  CurrentHighlightColors := FDefaultHighlightColors;
  CSMode := csmIgnoreCase;

  for i := 0 to Cmd.ParsedParamCount - 1 do
  begin
    Param := Cmd.ParsedParam[i];
    if not Param.Parsed then Continue;

    OptName := UpperCase(Param.OptionName);

    if (OptName = 'HC') or (OptName = 'HIGHLIGHT-COLORS') then
    begin
      CurrentHighlightColors := StripQuotes(Param.OptionValue);
      CurrentHighlightColors := TStr.ReplaceAll(CurrentHighlightColors, 'Lime', 'LightGreen', True);
      CurrentHighlightColors := TStr.ReplaceAll(CurrentHighlightColors, 'Fuchsia', 'LightMagenta', True);
      CurrentHighlightColors := TStr.ReplaceAll(CurrentHighlightColors, 'Purple', 'DarkMagenta', True);
      CurrentHighlightColors := TStr.ReplaceAll(CurrentHighlightColors, 'Aqua', 'Cyan', True);
    end

    else if (OptName = 'HT') or (OptName = 'HIGHLIGHT-TEXT') then
    begin
      AddToArray(StripQuotes(Param.OptionValue), CurrentHighlightColors, CSMode);
    end

    else if (OptName = 'S') or (OptName = 'CASE-SENSITIVE') then
    begin
      if Param.OptionValue = '1' then CSMode := csmCaseSensitive
      else if Param.OptionValue = '0' then CSMode := csmIgnoreCase
      else
      begin
        DisplayError('Invalid value for the "-s" option: ' + Param.OptionValue);
        DisplayTryHelp;
        ExitCode := TConsole.ExitCodeSyntaxError;
        Terminate;
        Break;
      end;
    end;
  end; // for


  if Terminated then Exit;

  if AppParams.SplitStr <> '' then
    AppParams.Text := TStr.ReplaceAll(AppParams.Text, AppParams.SplitStr, ENDL, True);


  cc := TConColorParser.Create;
  try

    if AppParams.TextColor <> TConsole.clNone then
    begin
      cc.DefaultTextColor := AppParams.TextColor;
      TConsole.SetTextColor(AppParams.TextColor);
    end;

    if AppParams.BackgroundColor <> TConsole.clNone then
    begin
      cc.DefaultBackgroundColor := AppParams.BackgroundColor;
      TConsole.SetBackgroundColor(AppParams.BackgroundColor);
    end;

    cc.CaseSensitive := False;
    cc.Text := AppParams.Text;
    for i := 0 to High(Arr) do cc.AddHighlightedText(Arr[i].Text, Arr[i].Colors, Arr[i].csMode);
    cc.Parse;
    cc.WriteText;

  finally
    cc.Free;
  end;

  if AppParams.AddEndlAtEnd then Writeln;

end;
{$endregion PerformMainAction}


{$region '                    Display... procs                  '}
procedure TApp.DisplayHelpAndExit(const ExCode: integer);
begin
  DisplayBanner;
  DisplayShortUsage;
  DisplayUsage;
  DisplayExtraInfo;

  ExitCode := ExCode;
  Terminate;
end;

procedure TApp.DisplayShortUsageAndExit(const Msg: string; const ExCode: integer);
begin
  if Msg <> '' then Writeln(Msg);
  DisplayShortUsage;
  DisplayTryHelp;
  ExitCode := ExCode;
  Terminate;
end;

procedure TApp.DisplayBannerAndExit(const ExCode: integer);
begin
  DisplayBanner;
  ExitCode := ExCode;
  Terminate;
end;

procedure TApp.DisplayMessageAndExit(const Msg: string; const ExCode: integer);
begin
  Writeln(Msg);
  ExitCode := ExCode;
  Terminate;
end;

procedure TApp.DisplayExamplesAndExit(const ExCode: integer);
begin
  DisplayBanner;
  DisplayExamples;
  ExitCode := ExCode;
  Terminate;
end;

{$endregion Display... procs}



end.
