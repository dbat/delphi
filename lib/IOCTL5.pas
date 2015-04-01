unit IOCTL5;
//CONVERTED FROM IOCTL.INC (VISUAL DEVSTUDIO 5) - I'm a plagiat afterall
//not required - just a collection of numbers (so did with WINDOWS.PAS ;))
//this version not including a structure/record that might be needed

//any comments just send to me: aa, a_@geocities.com ..obsolete!
//mailto: aa[at softindo dot]net

interface
type TMediaSerialNumberData = packed record
  SerialNumberLength, Result:integer;
  Reserved: array[0..1] of integer;
  SerialNumberData: array[0..0] of byte;
end;

const
//DeviceType
  File_Device_BEEP                = $00000001;
  File_Device_CD_ROM              = $00000002;
  File_Device_CD_ROM_File_System  = $00000003;
  File_Device_CONTROLLER          = $00000004;
  File_Device_DataLINK            = $00000005;
  File_Device_DFS                 = $00000006;
  File_Device_Disk                = $00000007;
  File_Device_Disk_File_System    = $00000008;
  File_Device_File_System         = $00000009;
  File_Device_INPORT_PORT         = $0000000A;
  File_Device_KEYBOARD            = $0000000B;
  File_Device_MAILSLOT            = $0000000C;
  File_Device_MIDI_IN             = $0000000D;
  File_Device_MIDI_OUT            = $0000000E;
  File_Device_MOUSE               = $0000000F;
  File_Device_MULTI_UNC_PROVIDER  = $00000010;
  File_Device_NAMED_PIPE          = $00000011;
  File_Device_NETWORK             = $00000012;
  File_Device_NETWORK_BROWSER     = $00000013;
  File_Device_NETWORK_File_System = $00000014;
  File_Device_NULL                = $00000015;
  File_Device_PARALLEL_PORT       = $00000016;
  File_Device_PHYSICAL_NETCARD    = $00000017;
  File_Device_PRINTER             = $00000018;
  File_Device_SCANNER             = $00000019;
  File_Device_SERIAL_MOUSE_PORT   = $0000001A;
  File_Device_SERIAL_PORT         = $0000001B;
  File_Device_SCREEN              = $0000001C;
  File_Device_SOUND               = $0000001D;
  File_Device_STREAMS             = $0000001E;
  File_Device_TAPE                = $0000001F;
  File_Device_TAPE_File_System    = $00000020;
  File_Device_TRANSPORT           = $00000021;
  File_Device_UNKNOWN             = $00000022;
  File_Device_VIDEO               = $00000023;
  File_Device_VIRTUAL_Disk        = $00000024;
  File_Device_WAVE_IN             = $00000025;
  File_Device_WAVE_OUT            = $00000026;
  File_Device_8042_PORT           = $00000027;
  File_Device_NETWORK_REDIRECTOR  = $00000028;
  File_Device_BATTERY             = $00000029;
  File_Device_BUS_EXTENDER        = $0000002A;
  File_Device_MODEM               = $0000002B;
  File_Device_VDM                 = $0000002C;
  File_Device_Mass_Storage        = $0000002D;

//Method
  Method_Buffered                 = 0;
  Method_IN_Direct                = 1;
  Method_OUT_Direct               = 2;
  Method_Neither                  = 3;

//Access
  File_Any_Access                 = 0;
  File_Read_Access                = ($0001);    // file & pipe
  File_Write_Access               = ($0002);    // file & pipe
//FSCTL Access
  File_Read_Data                  = File_Read_Access;
  File_Write_Data                 = File_Write_Access;

//Storage
  IOCTL_Storage_Base              = File_Device_MASS_Storage;// $002D
  IOCTL_Disk_Base                 = File_Device_Disk;        // $0007

//Partition
  Partition_ENTRY_UNUSED          = $00;      // Entry unused
  Partition_FAT_12                = $01;      // 12-bit FAT entries
  Partition_XENIX_1               = $02;      // Xenix
  Partition_XENIX_2               = $03;      // Xenix
  Partition_FAT_16                = $04;      // 16-bit FAT entries
  Partition_EXTENDED              = $05;      // Extended Partition entry
  Partition_HUGE                  = $06;      // Huge Partition MS-DOS V4
  Partition_IFS                   = $07;      // IFS Partition
  Partition_FAT32                 = $0B;      // FAT32
  Partition_FAT32_XINT13          = $0C;      // FAT32 using extended int13 services
  Partition_XINT13                = $0E;      // Win95 Partition using extended int13 services
  Partition_XINT13_EXTENDED       = $0F;      // Same as type 5 but uses extended int13 services
  Partition_PREP                  = $41;      // PowerPC Reference Platform (PReP) Boot Partition
  Partition_UNIX                  = $63;      // Unix

  VALID_NTFT                      = $C0;      // NTFT uses high order bits

{$WRITEABLECONST ON}
//IOCTL/FSCTL/SMART Code
  IOCTL_Storage_Check_Verify      : integer = 0;
  IOCTL_Storage_Media_Removal     : integer = 0;
  IOCTL_Storage_Eject_Media       : integer = 0;
  IOCTL_Storage_Load_Media        : integer = 0;
  IOCTL_Storage_RESERVE           : integer = 0;
  IOCTL_Storage_RELEASE           : integer = 0;
  IOCTL_Storage_Find_New_Devices  : integer = 0;
  IOCTL_Storage_Get_Media_Types   : integer = 0;

//VS2005
  IOCTL_Storage_Load_Media2       : integer = 0;
  IOCTL_Storage_Check_Verify2     : integer = 0;

  IOCTL_Storage_Ejection_Control  : integer = 0;
  IOCTL_Storage_MCN_Control       : integer = 0;

  IOCTL_Storage_Get_Media_Types_Ex: integer = 0;
  IOCTL_Storage_Get_Media_Serial_Number: integer = 0;
  IOCTL_Storage_Get_HotPlug_Info  : integer = 0;
  IOCTL_Storage_Set_HotPlug_Info  : integer = 0;

  IOCTL_Storage_Break_Reservation : integer = 0;
  IOCTL_Storage_Get_Device_Number : integer = 0;
  IOCTL_Storage_Predict_Failure   : integer = 0;
  IOCTL_Storage_Read_Capacity     : integer = 0;

//END VS2005

  IOCTL_Disk_Get_Drive_Geometry   : integer = 0;
  IOCTL_Disk_Get_Partition_Info   : integer = 0;
  IOCTL_Disk_Set_Partition_Info   : integer = 0;
  IOCTL_Disk_Get_Drive_Layout     : integer = 0;
  IOCTL_Disk_Set_Drive_Layout     : integer = 0;
  IOCTL_Disk_Verify               : integer = 0;
  IOCTL_Disk_Format_Tracks        : integer = 0;
  IOCTL_Disk_Reassign_Blocks      : integer = 0;
  IOCTL_Disk_Performance          : integer = 0;
  IOCTL_Disk_is_Writable          : integer = 0;
  IOCTL_Disk_Logging              : integer = 0;
  IOCTL_Disk_Format_Tracks_EX     : integer = 0;
  IOCTL_Disk_Histogram_Structure  : integer = 0;
  IOCTL_Disk_Histogram_Data       : integer = 0;
  IOCTL_Disk_Histogram_Reset      : integer = 0;
  IOCTL_Disk_Request_Structure    : integer = 0;
  IOCTL_Disk_Request_Data         : integer = 0;

  FSCTL_Lock_Volume               : integer = 0;
  FSCTL_Unlock_Volume             : integer = 0;
  FSCTL_Dismount_Volume           : integer = 0;
  FSCTL_Mount_DBLS_Volume         : integer = 0;
  FSCTL_Get_Compression           : integer = 0;
  FSCTL_Set_Compression           : integer = 0;
  FSCTL_Read_Compression          : integer = 0;
  FSCTL_Write_Compression         : integer = 0;

  SMART_Get_Version               : integer = 0;
  SMART_SEND_Drive_Command        : integer = 0;
  SMART_RCV_Drive_Data            : integer = 0;
{$WRITEABLECONST OFF}

//  procedure Init;

implementation

function Ctl_Code(DeviceType, FuncNo, Method, Access: integer): integer; begin
  Result:= (DeviceType shl 16) or (Access shl 14) or (FuncNo shl 2) or (Method)
end;

procedure Init; begin
  IOCTL_Storage_Check_Verify := Ctl_Code(IOCTL_Storage_Base, $0200, Method_Buffered, File_Read_Access);
  IOCTL_Storage_Media_REMOVAL := Ctl_Code(IOCTL_Storage_Base, $0201, Method_Buffered, File_Read_Access);
  IOCTL_Storage_Eject_Media := Ctl_Code(IOCTL_Storage_Base, $0202, Method_Buffered, File_Read_Access);
  IOCTL_Storage_Load_Media := Ctl_Code(IOCTL_Storage_Base, $0203, Method_Buffered, File_Read_Access);
  IOCTL_Storage_RESERVE := Ctl_Code(IOCTL_Storage_Base, $0204, Method_Buffered, File_Read_Access);
  IOCTL_Storage_RELEASE := Ctl_Code(IOCTL_Storage_Base, $0205, Method_Buffered, File_Read_Access);
  IOCTL_Storage_Find_New_Devices := Ctl_Code(IOCTL_Storage_Base, $0206, Method_Buffered, File_Read_Access);
  IOCTL_Storage_Get_Media_Types := Ctl_Code(IOCTL_Storage_Base, $0300, Method_Buffered, File_Any_Access);

//VS2005
  IOCTL_Storage_Load_Media2 := Ctl_Code(IOCTL_Storage_Base, $0203, Method_Buffered, File_Read_Access);
  IOCTL_Storage_Check_Verify2 := Ctl_Code(IOCTL_Storage_Base, $0200, Method_Buffered, File_Any_Access);

  IOCTL_Storage_Ejection_Control := Ctl_Code(IOCTL_Storage_Base, $0250, Method_Buffered, File_Any_Access);
  IOCTL_Storage_MCN_Control := Ctl_Code(IOCTL_Storage_Base, $0251, Method_Buffered, File_Any_Access);

  IOCTL_Storage_Get_Media_Types_Ex := Ctl_Code(IOCTL_Storage_Base, $0301, Method_Buffered, File_Any_Access);
  IOCTL_Storage_Get_Media_Serial_Number := Ctl_Code(IOCTL_Storage_Base, $0304, Method_Buffered, File_Any_Access);
  IOCTL_Storage_Get_HotPlug_Info := Ctl_Code(IOCTL_Storage_Base, $0305, Method_Buffered, File_Any_Access);
  IOCTL_Storage_Set_HotPlug_Info := Ctl_Code(IOCTL_Storage_Base, $0306, Method_Buffered, File_Read_Access or File_Write_Access);

  IOCTL_Storage_Break_Reservation := Ctl_Code(IOCTL_Storage_Base, $0405, Method_Buffered, File_Read_Access);
  IOCTL_Storage_Get_Device_Number := Ctl_Code(IOCTL_Storage_Base, $0420, Method_Buffered, File_Any_Access);
  IOCTL_Storage_Predict_Failure := Ctl_Code(IOCTL_Storage_Base, $0440, Method_Buffered, File_Any_Access);
  IOCTL_Storage_Read_Capacity := Ctl_Code(IOCTL_Storage_Base, $0450, Method_Buffered, File_Read_Access);
//END VS2005

  IOCTL_Disk_Get_Drive_Geometry := Ctl_Code(IOCTL_Disk_Base, $0000, Method_Buffered, File_Any_Access);
  IOCTL_Disk_Get_Partition_Info := Ctl_Code(IOCTL_Disk_Base, $0001, Method_Buffered, File_Read_Access);
  IOCTL_Disk_Set_Partition_Info := Ctl_Code(IOCTL_Disk_Base, $0002, Method_Buffered, File_Read_Access or File_Write_Access);
  IOCTL_Disk_Get_Drive_Layout := Ctl_Code(IOCTL_Disk_Base, $0003, Method_Buffered, File_Read_Access);
  IOCTL_Disk_Set_Drive_Layout := Ctl_Code(IOCTL_Disk_Base, $0004, Method_Buffered, File_Read_Access or File_Write_Access);
  IOCTL_Disk_Verify := Ctl_Code(IOCTL_Disk_Base, $0005, Method_Buffered, File_Any_Access);
  IOCTL_Disk_Format_Tracks := Ctl_Code(IOCTL_Disk_Base, $0006, Method_Buffered, File_Read_Access or File_Write_Access);
  IOCTL_Disk_Reassign_Blocks := Ctl_Code(IOCTL_Disk_Base, $0007, Method_Buffered, File_Read_Access or File_Write_Access);
  IOCTL_Disk_Performance := Ctl_Code(IOCTL_Disk_Base, $0008, Method_Buffered, File_Any_Access);
  IOCTL_Disk_is_Writable := Ctl_Code(IOCTL_Disk_Base, $0009, Method_Buffered, File_Any_Access);
  IOCTL_Disk_Logging := Ctl_Code(IOCTL_Disk_Base, $000A, Method_Buffered, File_Any_Access);
  IOCTL_Disk_Format_Tracks_EX := Ctl_Code(IOCTL_Disk_Base, $000B, Method_Buffered, File_Read_Access or File_Write_Access);
  IOCTL_Disk_Histogram_Structure := Ctl_Code(IOCTL_Disk_Base, $000C, Method_Buffered, File_Any_Access);
  IOCTL_Disk_Histogram_Data := Ctl_Code(IOCTL_Disk_Base, $000D, Method_Buffered, File_Any_Access);
  IOCTL_Disk_Histogram_Reset := Ctl_Code(IOCTL_Disk_Base, $000E, Method_Buffered, File_Any_Access);
  IOCTL_Disk_Request_Structure := Ctl_Code(IOCTL_Disk_Base, $000F, Method_Buffered, File_Any_Access);
  IOCTL_Disk_Request_Data := Ctl_Code(IOCTL_Disk_Base, $0010, Method_Buffered, File_Any_Access);

  FSCTL_Lock_Volume := Ctl_Code(File_Device_File_System, 6, Method_Buffered, File_Any_Access);
  FSCTL_Unlock_Volume := Ctl_Code(File_Device_File_System, 7, Method_Buffered, File_Any_Access);
  FSCTL_Dismount_Volume := Ctl_Code(File_Device_File_System, 8, Method_Buffered, File_Any_Access);
  FSCTL_Mount_DBLS_Volume := Ctl_Code(File_Device_File_System, 13, Method_Buffered, File_Any_Access);
  FSCTL_Get_Compression := Ctl_Code(File_Device_File_System, 15, Method_Buffered, File_Any_Access);
  FSCTL_Set_Compression := Ctl_Code(File_Device_File_System, 16, Method_Buffered, File_Read_Data or File_Write_Data);
  FSCTL_Read_Compression := Ctl_Code(File_Device_File_System, 17, Method_Neither, File_Read_Data);
  FSCTL_Write_Compression := Ctl_Code(File_Device_File_System, 18, Method_Neither, File_Write_Data);

  SMART_Get_Version := CTL_CODE(IOCTL_Disk_Base, $0020, Method_Buffered, File_Read_Access);
  SMART_SEND_Drive_Command := CTL_CODE(IOCTL_Disk_Base, $0021, Method_Buffered, File_Read_Access or File_Write_Access);
  SMART_RCV_Drive_Data := CTL_CODE(IOCTL_Disk_Base, $0022, Method_Buffered, File_Read_Access or File_Write_Access);
end;

initialization
  Init;

END.
