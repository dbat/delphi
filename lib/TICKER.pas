unit ticker;

interface
function tickstotime(const ticks: int64): string;

implementation
uses windows, sysutils;

function tickstotime(const ticks: int64): string;
const
  H_PERDAY = 24;
  M_PERHOUR = 60;
  S_PERMINUTE = 60;
  S_PERHOUR = S_PERMINUTE * M_PERHOUR;
  S_PERDAY = S_PERHOUR * H_PERDAY;

  THOUSAND = 1000;
  MILLION = THOUSAND * THOUSAND;
var
  hz, tm: int64;
  d, h, m, s, ms, ns: integer;
begin
  QueryPerformanceFrequency(hz);
  tm := ticks * MILLION div hz; // in nanoseconds
  ns := tm mod THOUSAND;
  ms := tm mod MILLION div THOUSAND;

  tm := ticks div hz; // now in seconds
  s := tm mod S_PERMINUTE;
  m := tm div S_PERMINUTE mod M_PERHOUR;
  h := tm div S_PERHOUR mod H_PERDAY;
  d := tm div S_PERDAY;
  if d > 0 then
    Result := format('%d %.02d:%.02d:%.02d.%.03d%.03d', [d, h, m, s, ms, ns])
  else
    Result := format('%.02d:%.02d:%.02d.%.03d%.03d', [h, m, s, ms, ns])
end;

end.

