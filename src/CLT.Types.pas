unit CLT.Types;

{$IFDEF FPC}
  {$mode delphi}
{$ENDIF}

interface



type

  TAppParams = record
    Text: string;
    SplitStr: string;              // -n
    AddEndlAtEnd: Boolean;         // -nn
    GithubUrl: string;             // --github
    AddLogHighlights: Boolean;     // -l
    TextColor: Byte;
    BackgroundColor: Byte;
  end;

  
implementation

end.
