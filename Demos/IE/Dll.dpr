library Dll;

uses
  Windows, WinInet, HookUtils;

var
  HttpOpenRequestWNext: function(hConnect: HINTERNET; lpszVerb: LPWSTR;
    lpszObjectName: LPWSTR; lpszVersion: LPWSTR; lpszReferrer: LPWSTR;
    lplpszAcceptTypes: PLPSTR; dwFlags: DWord;
    dwContext: DWORD_PTR): HINTERNET; stdcall;

function HttpOpenRequestWCallBack(hConnect: HINTERNET; lpszVerb: LPWSTR;
  lpszObjectName: LPWSTR; lpszVersion: LPWSTR; lpszReferrer: LPWSTR;
  lplpszAcceptTypes: PLPSTR; dwFlags: DWord;
  dwContext: DWORD_PTR): HINTERNET; stdcall;
var
  S: string;
begin
  // ��ֱ�ӵ���ԭʼ����
  Result := HttpOpenRequestWNext(hConnect, lpszVerb, lpszObjectName, lpszVersion,
    lpszReferrer, lplpszAcceptTypes, dwFlags, dwContext);

  if Result = nil then
  begin
    // ��ӡ����...
    Exit;
  end;
  // ����Զ����http��ͷ
  S := 'X-MyHttpHeader: HeaderValue';
  if not Wininet.HttpAddRequestHeaders(Result, PChar(S), Length(S),
    Wininet.HTTP_ADDREQ_FLAG_ADD or Wininet.HTTP_ADDREQ_FLAG_REPLACE) then
  begin
    // ��ӡ����...
    Exit;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//��ƣ�Lsuper 2016.10.09
//���ܣ���ʼ�����ҽ� API
//������
//ע�⣺��� HookProc �� DLL û�б� LoadLibrary �� Hook ��ʧ�ܣ��������ֹ� Load
////////////////////////////////////////////////////////////////////////////////
procedure DllEntryPoint(dwReason: DWord);
begin
  case dwReason of
    DLL_PROCESS_ATTACH:
      begin
        if HookUtils.HookProc('WinInet.dll', 'HttpOpenRequestW', @HttpOpenRequestWCallBack, @HttpOpenRequestWNext) then
        begin
          // Hook �ɹ�...
        end
        else
        begin
          // Hook ʧ��...
        end;
      end;
    DLL_PROCESS_DETACH:
      begin
        if HookUtils.UnHookProc(@HttpOpenRequestWNext) then
        begin
          // UnHook �ɹ�...
        end
        else
        begin
          // UnHook ʧ��...
        end;
      end;
    DLL_THREAD_ATTACH:
      begin
      end;
    DLL_THREAD_DETACH:
      begin
      end;
  end;
end;

begin
  DllProc := @DllEntryPoint;
  DllEntryPoint(DLL_PROCESS_ATTACH);
end.