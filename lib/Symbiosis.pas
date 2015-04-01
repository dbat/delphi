unit Symbiosis;

interface
const
  SM_BIOS_INFO = 0;
  SM_SYS_INFO = 1;
  SM_MODULE_INFO = 1;
  SM_CHASSIS_INFO = 0;
  SM_CPU_INFO = 4;
  SM_CACHE_INFO = 7;
  SM_SLOTS_INFO = 9;
  SM_PHYS_MEM_ARRAY = 16;
  SM_MEM_DEVICE = 17;
  SM_MEM_ARRAY_MAP = 19;
  SM_MEM_DEVICE_MAP = 20;
  SM_BOOT_INFO = 32;

  SMF_CHASSIS_LOCKED = 1 shl 7;

  SMC_ENUM_BOARD = 0;
  SMC_ENUM_STRUCT = 1 shl 7;

  //SMV_LEGACY = 0;
  //SMV_50 = 1;
  //SMV_33 = 1 shl 1;
  //SMV_29 = 1 shl 2;

//Base Board Feature Flags
//    SMFBOARD_HOSTING = 1;
//    SMFBOARD_ORPHAN = 1 shl 1;
//    SMFBOARD_REMOVABLE = 1 shl 2;
//    SMFBOARD_REPLACEABLE = 1 shl 3;
//    SMFBOARD_HOTSWAPPABLE = 1 shl 4;

type

  IDStr = type byte;
  dword = longword;
  qword = packed record
    case integer of
      0: (I: int64);
      1: (C1, C2: cardinal);
      2: (bytes: packed array[0..7] of byte);
      //9: (D: double);
  end;

  TSMStructHeader = packed record
    StructType: byte;
    Length: byte;
    Handle: word;
  end;

  _TBIOSCharacteristic = (bcxReserved0, bcxReserved1, bcxUnknown, bcxNotSupported,
    bcxISA, bcxMCA, bcxEISA, bcxPCI, bcxPCMCIA, bcxPnP, bcxAPM, bcxFlashBIOS,
    bcxShadowBIOS, bcxVESA, bcxESCD, bcxBootCDROM, bcxBootSelect, bcxROMSocket,
    bcxBootPCMCIA, bcxEIDE, bcxFloppyNEC9800, bcxFloppyToshiba, bcxFloppy360K,
    bcxFloppy1440K, bcxFloppy720K, bcxFloppy2880K, bcxPrintScreen, bcxKeyboard,
    bcxSerial, bcxPrinter, bcxCGA, bcxPC98);

  _TBIOSCharacteristicExt1 = (bcxACPI, bcxLegacyUSB, bcxAGP, bcxBootI2O,
    bcxBootLS120, bcxBootZIPDrive, bcxBoot1394, bcxSmartBattery);

  _TBIOSCharacteristicExt2 = (bcxBootSpec, bcxFKeyInitNetBoot, bcxEnablePushContent);

  _TBIOSVendorCharacteristic = 0..15;
  _TSystemVendorCharacteristic = 0..15;

  TBIOSCharacteristics = set of _TBIOSCharacteristic;
  TBIOSCharacteristicsExt1 = set of _TBIOSCharacteristicExt1;
  TBIOSCharacteristicsExt2 = set of _TBIOSCharacteristicExt2;

  TBIOSVendorCharacteristics = set of _TBIOSVendorCharacteristic;
  TSystemVendorCharacteristics = set of _TSystemVendorCharacteristic;

  T00_BIOSInfo = packed record // BIOS Information
    Header: TSMStructHeader; // v2.0+
    _Vendor, _BIOSVersion: IDStr; // v2.0+
    BIOSBaseAddress: word; // v2.0+
    _BIOSDate: IDStr; // v2.0+
    ROMSize: byte; // v2.0+
    BIOSCharacteristics: TBIOSCharacteristics; // v2.1+
    BIOSVendorCharacteristics: TBIOSVendorCharacteristics; // v2.1+
    SystemVendorCharacteristics: TSystemVendorCharacteristics; // v2.1+
    CharacteristicsExt1: TBIOSCharacteristicsExt1; // v2.4+
    CharacteristicsExt2: TBIOSCharacteristicsExt2; // v2.4+
    SystemBIOSRelease: packed array[0..1] of byte; // v2.4+
    EmbeddedControllerRelease: packed array[0..1] of byte; // v2.4+
  end;

  TWakeup = (wkupReserved, wkupOther, wkupUnknown, wkupAPMTimer, wkupModemRing,
    wkupLANRemote, wkupPowerSwitch, wkupPCI_PME, wkupACPowerRestored);

  T001_SystemInfo = packed record // v2.0+ System Information
    Header: TSMStructHeader; // v2.0+
    _Manufacturer, _ProductName,
      _Version, _SerialNumber: IDStr; // v2.0+
    UUID: TGUID; // v2.1+
    WakeupType: TWakeup; // v2.1+
    _SKUNumber, _Family: IDStr; // v2.4+
  end;

  TBaseBoard = (bbdInvalid, bbdUnknown, bbdOther, bbdServerBlade,
    bbdConnectivitySwitch, bbdSysMgtModule, bbdProcessorModule,
    bbdIOModule, bbdMemoryModule, bbdDaughterBoard, bbdMotherBoard,
    bbdProcessorMemoryModule, bbdProcessorIOModule, bbdInterconnectionBoard);

  _TBaseBoardFeatureFlag = (bbfHosting, bbfOrphan,
    bbfRemovable, bbfReplaceable, bbfHotSwapable);

  TBaseBoardFeatureFlags = set of _TBaseBoardFeatureFlag;

  T002_ModuleInfo = packed record // Base Board/Module Information
    Header: TSMStructHeader;
    _Manufacturer, _ProductName,
      _Version, _SerialNumber, _AssetTag: IDStr;
    FeaturFlags: TBaseBoardFeatureFlags; // should be $Z1
    _LocationInChassis: IDStr;
    hChassis: word;
    BoardType: TBaseBoard;
    NumberOfCOH: byte;
    COHList: packed array[0..0] of word;
  end;

  TChassis = (chssInvalid, chssOther, chssUnknown, chssDesktop,
    chssLowProfileDesktop, chssPizzaBox, chssMiniTower, chssTower,
    chssPortable, chssLapTop, chssNotebook, chssHandHeld, chssDockingStation,
    chssAllInOne, chssSubNotebook, chssSpacesaving, chssLunchBox,
    chssMainServerChassis, chssExpansionChassis, chssSubChassis,
    chssBusExpansionChassis, chssPeripheralChassis, chssRAIDChassis,
    chssRackMountChassis, chssSealedCasePC, chssMultiSystemChassis);
  TChassisState = (csstInvalid, csstOther, csstUnknown,
    csstSafe, csstWarning, csstCritical, csstNonRecoverable);
  TChassisSecurityStatus =
    (csseInvalid, csseOther, csseUnknown, csseNone, csseExtIFLockedOut, csseExtIFEnabled);

  //TContainedElement = packed record // v2.3+
  //  CEType: TBaseBoard;
  //  CEMin, CEMax: byte;
  //  CEData: record end;
  //end;

  T003_ChassisInfo = packed record // v2.0+ System Enclosure/Chassis Information  (Type 3)
    Header: TSMStructHeader; // v2.0+
    _Manufacturer: IDStr; // v2.0+
    ChassisType: TChassis; // v2.0+
    _Version, _SerialNumber, _AssetTag: IDStr; // v2.0+
    BootUpState, PowerSupplyState, ThermalState: TChassisState; // v2.1+
    SecurityStatus: TChassisSecurityStatus; // v2.1+
    OEMDefined: cardinal; // v2.3+
    Height, NumberOfPowerCords: byte; // v2.3+
    CECount, CERecordLength: byte; // v2.3+
    ContainedElements: packed array[0..0] of packed record //TContainedElement; // v2.3+
      CEType: TBaseBoard;
      CEMin, CEMax: byte;
      CEData: record end;
    end;
  end;

  _TLegacyVoltage = (lv50CVolt, lv33CVolt, lv29CVolt);
  TLegacyVoltages = set of _TLegacyVoltage;

  TProcessor = (prcInvalid, prcOther, prcUnknown, prcCentralProcsessor,
    prcMathProcessor, prcDSPProcessor, prcVideoProcessor);
  TCPUStatusLo = (cpusUnknown, cpusEnabled, cpusDisabled, cpusPOSTError, cpusIdle,
    cpusReserved, cpusOther);
{$I TProcessors.inc}
  T004_ProcessorInfo = packed record // Processor Information  (Type 4)
    Header: TSMStructHeader; // v2.0+
    _SocketDesignation: IDStr; // v2.0+
    ProcessorType: TProcessor; // v2.0+
    ProcessorFamily: TProcessorFamily; // v2.0+
    _Manufacturer: IDStr; // v2.0+
    //ProcessorID: packed array[0..1] of dword; // v2.0+
    ProcessorID: qword; // v2.0+
    _ProcessorVersion: IDStr; // v2.0+
    Voltage: TLegacyVoltages; // v2.0+
    ExternalClock, MaxSpeed, CurrentSpeed: word; // v2.0+
    Status: TCPUStatusLo; // v2.0+
    ProcessorUpgrade: TProcessorUpgrade; // v2.0+
    LCacheHandles: packed array[0..2] of word; // v2.1+
    _SerialNumber, _AssetTag, _PartNumber: IDStr; // v2.3+
  end;

  TMCIErrorDetectingMethod = (mcedInvalid, mcedOther, mcedUnknown, mcedNone,
    mced8bitParity, mced32bitECC, mced64bitECC, mced128bitECC, mcedCRC);

  TMCIInterleaveSupport = (mcilInvalid, mcilOther, mcilUnknown, mcil1WayInterleave,
    mcil2WayInterleave, mcil4WayInterleave, mcil8WayInterleave, mcil16WayInterleave);

  _TMCIErrorCorrectingCapability = (mcecOther, mcecUnknown, mcecNone,
    mcecSingleBitECC, mcecDoubleBitECC, mcecErrorScrubbling);

  _TMCIMemorySpeed = (mmspInvalid, mmspOther, mmspUnknown, mmsp70ns, mmsp60ns, mmsp50ns);

  _TMMIMemory = (memOther, memUnknown, memStandard, memFastPageMode, memEDO,
    memParity, memECC, SIMM, memDIMM, memBurstEDO, memSDRAM, memRDRAM, memFlash);

  TMCIErrorCorrectingCapabilities = set of _TMCIErrorCorrectingCapability;
  TMCIMemorySpeeds = set of _TMCIMemorySpeed;
  TMMIMemories = set of _TMMIMemory;

  T005_MemoryControllerInfo = packed record // OBSOLETE: Memory Controller Information (Type 5)
    Header: TSMStructHeader; // v2.0+
    ErrorDetectingMethod: TMCIErrorDetectingMethod; // v2.0+
    ErrorDetectingCapabilities: TMCIErrorCorrectingCapabilities; // v2.0+
    SupportedInterleave, CurrentInterleave: TMCIInterleaveSupport; // v2.0+
    MaxMemoryModuleSize: byte; // v2.0+
    SupportedSpeed: TMCIMemorySpeeds; // v2.0+
    SupportedMemoryTypes: TMMIMemories; // v2.0+
    MemoryModuleVoltage: TLegacyVoltages; // v2.0+
    NumberOfAssociatedMemorySlots: byte; // v2.0+
    MemoryModuleConfigHandles: packed array[0..0] of word; // v2.0+
    ECCs: TMCIErrorCorrectingCapabilities; // v2.1+
  end;

  _TMMIErrorState = (mmesUncorrectableError, mmesCorrectableError, mmesEventLogged);
  TMMIErrorsStatus = set of _TMMIErrorState;

  T006_MemoryModuleInfo = packed record // OBSOLETE: Memory Module Information (Type 6)
    Header: TSMStructHeader;
    _SocketDesignation: IDStr;
    BankConnections: byte; //  2nibbles $F = no connection
    CurrentSpeed: byte;
    CurrentMemoryType: TMMIMemories;
    InstalledSize, EnabledSize: byte;
    ErrorStatus: TMMIErrorsStatus;
  end;

  TCacheErrorCorrection = (caecInvalid, caecOther, caecUnknown, caecNone,
    caecParity, caecSingleBitECC, caecMultiBitECC);

  TSystemCache = (sycaInvalid, sycaOther, sycaUnknown, sycaInstruction, sycaData, sycaUnified);

  TCacheAssociativity = (cassInvalid, cassOther, cassUnknown, cassDirectMapped,
    cass2WaySetAssoc, cass4WaySetAssoc, cassFullyAssoc, cass8WayAssoc, cass16WayAssoc);

  _TCacheConfig = (cacfCLbit0, cacfCLbit1, cacfCLbit2, cacfSocketed, cacfInvalid,
    cacfExternal, cacfReserved, cacfEnabled, cacfWriteBack, cacfVariable);

  _TCacheSRAM = (casrOther, casrUnknown, casrNonBurst, casrBurst,
    casrPipelineBurst, casrSynchronous, casrAsynchronous,
    casrReserved1, casrReservedsToFFh); // keep them for alignment!

  TCacheConfigSet = set of _TCacheConfig;
  TCacheSRAMSet = set of _TCacheSRAM;

  T007_CacheInfo = packed record // cache Information (Type 7)
    Header: TSMStructHeader; // v2.0+
    _SocketDesignation: IDStr; // v2.0+
    CacheConfig: TCacheConfigSet; // v2.0+
    MaxCacheSize, InstalledCacheSize: word; // v2.0+
    SupportedSRAMType, CurrentSRAMType: TCacheSRAMSet; // v2.0+
    CacheSpeed: byte; // v2.1+
    ErrorCorrectionType: TCacheErrorCorrection; // v2.1+
    SystemCacheType: TSystemCache; // v2.1+
    Associativity: TCacheAssociativity; // v2.1+
  end;

  TConnector = (conNone, conCentronics, conMiniCentronics, conProprietary,
    conDB25pinMale, conDB25pinFemale, conDB15pinMale, conDB15pinFemale, conDB9pinMale,
    conDB9pinFemale, conRJ11, conRJ45, con50pinMiniSCSI, conMicroDN, conPS2, conInfraRed,
    conHPHIL, conAccessBusUSB, conSSASCSI, conCircularDIN8Male, conCircularDIN8Female,
    conOnBoardIDE, conOnBoardFloppy, con9pinDualInline, con25pinDualInline, con50pinDualInline,
    con68pinDualInline, conOnBoardSoundCDROM, conMiniCentronicsType14, conMiniCentronicsType26,
    conMiniJackHeadPhone, conBNC, con1394, conPC98, conPC98Hireso, conPCH98, conPC98Note,
    conPC98Full, conOther

    );
  TPort = (portNone, portParallelXTAT, portParallelPS2, portParallelECP, portParallelEPP,
    portParallelECPEPP, portSerialXTAT, portSerial16450, portSerial16550, portSerial16550A,
    portSCSI, portMIDI, portJoyStick, portKeyboard, portMouse, portSSASCSI, portUSB, port1394,
    portPCMCIA1, portPCMCIA2, portPCMCIA3, portCardBus, portAccessBus, portSCSI2, portSCSIWide,
    portPC98, portPC98Hireso, portPCH98, portVideo, portAudio, portModem, portNetwork,
    port8251, port8251FIFO
    );

  T008_PortConnectorInfo = packed record
    Header: TSMStructHeader;
    _InternalRefDesignator: IDStr;
    InternalConnectorType: TConnector;
    _ExternalRefDesignator: IDStr;
    ExternalConnectorType: TConnector;
    PortType: TPort;
  end;

  _TSlotCharacteristic1 = (slcxUnknown, slcxProvides50CVolt, slcxProvides33CVolt, slcxOpenShared,
    slcxSupportPCCard16, slcxSupportCardBus, slcxSupportZoomVideo, slcxSupportModemRing);
  _TSlotCharacteristic2 = (slcxSupportPME, slcxSupportHotPlug, slcxSupportSMBUSSignal);

  TSlotCharacteristics1 = set of _TSlotCharacteristic1;
  TSlotCharacteristics2 = set of _TSlotCharacteristic2;

  TSlotLength = (slenInvalid, slenOther, slenUnknown, slenShor, slenLong);
  TSlotCurrentUsage = (slcuInvalid, slcuOther, slcuUnknown, slcuAvailable, slcuInUse);
  TSlotDataBusWidth = (sldwInvalid, sldwOther, sldwUnknown, sldw8bit, sldw16bit, sldw32bit,
    sldw64bit, sldw128bit, sldw1x, sldw2x, sldw4x, sldw8x, sldw12x, sldw16x, sldw32x);
  TSlot = (slotInvalid, slotOther, slotUnknown, slotISA, slotMCA, slotEISA, slotPCI,
    slotPCMCIA, slotVLVESA, slotProprietary, slotProcessorCard, slotPropietaryMemCard,
    slotIORiserCard, slotNuBus, slotPCI66MHz, slotAGP, slotAGP2X, slotAGP4X, slotPCIX,
    slotAGP8x, slotPC98C20, slotPC98C24, slotPC98CE, slotPC98LocalBus, slotPC98Caard,
    slotPCIExpress);

  T009_SystemSlots = packed record
    Header: TSMStructHeader; // v2.0+
    _SlotDesignation: IDStr; // v2.0+
    SlotType: TSlot; // v2.0+
    SlotDataBusWidth: TSlotDataBusWidth; // v2.0+
    CurrentUsage: TSlotCurrentUsage; // v2.0+
    SlotLength, SlotID: byte; // v2.0+
    SlotCharacteristics1: TSlotCharacteristics1; // v2.0+
    SlotCharacteristics2: TSlotCharacteristics2; // v2.1+
  end;

  TOnBoardDevice = (obdInvalid, obdOther, obdUnknown, obdVideo, obdSCSIController,
    obdEthernet, obdTokenRing, obdSound);

  T010_OnBoardDeviceInfo = packed record
    // length implicitly defines number of device presents
    Header: TSMStructHeader;
    DeviceType: packed array[0..0] of TOnBoardDevice;
    _DescriptionString: packed array[0..0] of IDStr;
  end;

  T011_OEMStrings = packed record
    Header: TSMStructHeader;
    Count: byte;
  end;

  T012_SystemConfigurationOptions = packed record
    Header: TSMStructHeader;
    Count: byte;
  end;

  T013_BIOSLanguageInfo = packed record
    Header: TSMStructHeader; // v2.0+
    InstallableLanguage: byte; // v2.0+
    Flags: byte; // v2.1+  <-- note here!
    Reserved: packed array[0..14] of byte; // v2.0+
    _CurrentLanguage: IDStr; // v2.0+
  end;

  T014_GroupAssociation = packed record
    Header: TSMStructHeader;
    _GroupName: IDStr;
    ItemType: byte;
    ItemHandle: word;
  end;

  _TLogState = (logsValid, logsFull, logsReservedsTo07);
  TLogStatus = set of _TLogState;

  TAccessMethod = (acsmIndexedIO1x8bit, acsmIndexedIO2x8bit, acsmIndexedIO1x16bit,
    acsmMemoryMapped, acsmUseGPNVData, acsmReservedsTo7Fh);

  TEventLog = (evReserved, evSingleBitECCError, evMultiBitECCError, evParityError,
    evBusTimeOut, evIOChannelCheck, evSoftwareNMI, evPOSTMemResize, evPOSTError,
    evPCIParityError, evPCISystemError, evCPUFailure, evEISATimeOut, evMemLogDisabled,
    evEventLogDisabled, evReserved2, evSysLimitExceeded, evAsyncTimeExpired, evSysConfigInfo,
    evHardDiskInfo, evSystemReconfigured, evCPUComplexError, evLogAreaReset, evSystemBoot);

  TEventLogData = (evdNone, evdHandle, evdMultiEvent, evdMultiEventHandle,
    evdPostResultsBitmap, evdMultiEventManagementType, evdUnusedTo7Fh);

  TPostResultBitmapError1 = (
    bmpeChannel2Timer, bmpeMasterPIC, bmpeSlavePIC, bmpeCMOSBattery, bmpeCMOSNotSet,
    bmpeCMOSChecksum, bmpeCMOSConfig, bmpeMouseKBSwap, bmpeKBLocked, bmpeKBNotFunc,
    bmpeKBControllerNotFunc, bmpeCMOSSizeDiffer, bmpeMemDecreased, bmpeCacheMemory,
    bmpeFloppy0, bmpeFloppy1, bmpeFloppyController, bmpeATADrivesReduced, bmpeCMOSTimeNotset,
    bmpeDDCMonitorConfigChange, bmpeReserved20, bmpeReserved21, bmpeReserved22, bmpeReserved23,
    bmpeSecondwordValid, bmpeReserved25, bmpeReserved26, bmpeReserved27,
    bmpe28, bmpe29, bmpe30, bmpe31
    );

  TPostResultBitmapError2 = (bmpe0, bmpe1, bmpe2, bmpe3, bmpe4, bmpe5, bmpe6,
    bmpePCIMemConflict, bmpePCIIOConflict, bmpePCIIRQConflict, bmpePNPMemConflict,
    bmpePNPMem32Conflict, bmpePNPIOConflict, bmpePNPIRQConflict, bmpePNPDMAConflict,
    bmpeBadPNPSerialIDCheck, bmpeBadPNPResDataCheck, bmpeStaticResConflict,
    bmpeNVRAMCheck, bmpeSysBoardDeviceConflict, bmpeOutputDevNotFound, bmpeInputDevNotFound,
    bmpeBootDevNotFound, bmpeNVRAMJPCleared, bmpeNVRAMDataInvalid, bmpeFDCResConflict,
    bmpePriATAReConflict, bmpeSecATAReConflict, bmpeLPTPortResCOnflict,
    bmpeCOM1ResConflict, bmpeCOM2ResConflict, bmpeAudioResConflict);

  T015_SystemEventLog = packed record
    Header: TSMStructHeader; // v2.0+
    LogAreaLength, LogHeaderStartOffset, LogDataStartOffset: word; // v2.0+
    AccesMethod: byte; // v2.0+
    LogStatus: TLogStatus; // v2.0+
    LogChangeToken, AccessMethodAddress: dword; // v2.0+
    LogHeaderFormat: byte; // v2.1+
    NumberOfSupportedLogTypeDescriptor: byte; // v2.1+
    LengthOfEachLogTypeDescriptor: byte; // v2.1+
    List {OfSupportedEventLogTypeDescriptors}: array[0..0] of packed record // v2.1+
      LogType: TEventLog;
      LogDataType: TEventLogData;
    end;
  end;
  TPMALocation = (pmlkInvalid, pmlkOther, pmlkUnnknown, pmlkSysBoard,
    pmlkISA, pmlkEISA, pmlkPCI, pmlkMCA, pmlkPCMCIA, pmlkPropietary,
    pmlkNuBus, pmlkPC98C20, pmlkPC98C24, pmlkPC98E, pmlkPC98LocalBus);
  TPMAUse = (pmusInvalid, pmusOther, pmusUnknown, pmusSystemMemory, pmusVideoMemory, pmusFlashMemory,
    pmusNonVolatile, pmusCache);
  TPMAMemoryErrorCorrection = (pmecInvalid, pmecOther, pmecUnknown, pmecNone, pmecParity,
    pmecSingleBitECC, pmecMultiBitECC);

  T016_PhysicalMemoryArray = packed record
    Header: TSMStructHeader; // v2.1+
    Location: TPMALocation; // v2.1+
    Use: TPMAUse; // v2.1+
    MemoryErrorCorrection: TPMAMemoryErrorCorrection; // v2.1+
    MaxCapacity, hMemoryErrorInfo, NumberOfMemoryDevices: word; // v2.1+
  end;

  TFormFactor = (ffacInvalid, ffacOther, ffacUnknown, ffacSIM, ffacSIP, ffacChip, ffacDIP,
    ffacZIP, ffacProprietary, ffacTSOP, ffacRowChip, ffacRIMM, ffacSODIMM, ffacSRIMM);

  TMemoryDevice = (mdevInvalid, mdevOther, mdevUnknown, mdevDRAM,
    mdevEDRAM, mdevVRAM, mdevSRAM, mdevRAM, mdevROM, mdevFlash, mdevEEPROM, mdevFEPROM,
    mdevEPROM, mdevCDRAM, mdev3DRAM, mdevSDRAM, mdevRDRAM, mdevDDR, mdevDDR2);

  _TMemoryDeviceDetail = (mdtlReserved, mdtlOther, mdtlUnknown, mdtlFastPaged, mdtlStaticColumn,
    mdtlPseudoStatic, mdtlRAMBUS, mdtlSynchronous, mdtlCMOS, mdtlEDO, mdtlWindowDRAM,
    mdtlCacheDRAM, mdtlNonVolatile);

  TMemoryDeviceDetails = set of _TMemoryDeviceDetail;

  T017_MemoryDevice = packed record
    Header: TSMStructHeader; // v2.1+
    hPhysicalMemArray: word; // v2.1+
    hMemErrorInfo: word; // v2.1+
    TotalWidth, DataWidth, Size: word; // v2.1+
    FormFactor: TFormFactor; // v2.1+
    DeviceSet: byte; // v2.1+
    _DeviceLocator, _BankLocator: IDStr; // v2.1+
    MemoryType: TMemoryDevice; // v2.1+
    TypeDetail: TMemoryDeviceDetails; // v2.1+
    Speed: word; // v2.3+
    _Manufacturer, _SerialNumber, _AssetTag, _PartNumber: IDStr; // v2.3+

  end;

  TMemoryError = (merrInvalid, merrOther, merrUnknown, merrOK, merrBadRead,
    merrParity, merrSingleBit, merrDoubleBit, merrMultiBit, merrNibble, merrChecksum,
    merrCRC, merrCorrectedSingleBit, merrCorrected, merrUncorrectable);

  TMemoryErrorGranularity = (megrInvalid, megrOther, megrUnknown, megrDeviceLevel, megrParttitionLevel);
  TMemoryErrorOperation = (meopInvalid, meopOther, meopUnknown, meopRead, meopWrite, meopPartialWrite);

  T018_32bitMemoryErrorInfo = packed record
    Header: TSMStructHeader; // v2.1+
    ErrorType: TMemoryError; // v2.1+
    ErrorGranularity: TMemoryErrorGranularity; // v2.1+
    ErrorOperation: TMemoryErrorOperation; // v2.1+
    VendorSyndrome, MemoryArrayErrorAddress,
      DeviceErrorAddress, ErrorResolution: dword; // v2.1+
  end;

  T019_MemoryArrayMappedAddress = packed record
    Header: TSMStructHeader; // v2.1+
    StartingAddress, EndingAddress: dword; // v2.1+
    hMemoryArray: word; // v2.1+
    PartitionWidth: byte; // v2.1+
  end;

  T020_MemoryDeviceMappedAddress = packed record
    Header: TSMStructHeader; // v2.1+
    StartingAddress, EndingAddress: dword; // v2.1+
    hMemoryDevice, hMemArrayMappedAddress: word; // v2.1+
    PartitionRowPos, InterleavePos, InterleveDataDepth: byte; // v2.1+
  end;

  TPointingDevice = (ptdvInvalid, ptdvOther, ptdvUnknown, ptdvMouse, ptdvTrackBall,
    ptdvTrackPoint, ptdvGlidePoint, ptdvTouchPad, ptdvTouchScreen, ptdvOpticalSensor);
  TPointingDeviceInterface = (ptifInvalid, ptifOther, ptifUnknown, ptifSerial, ptifPS2,
    ptifInfraRed, ptifHPHIL, ptifBusMouse, ptifADB, ptifDB9, ptifMicroDN, ptifUSB);

  T021_BuiltInPointingDevice = packed record
    Header: TSMStructHeader; // v2.1+
    DeviceType: TPointingDevice; // v2.1+
    DeviceInterface: TPointingDeviceInterface; // v2.1+
    NumberOfButtons: byte; // v2.1+
  end;

  TDeviceChemistry = (chemInvalid, chemOther, chemUnknown, chemLeadAcid, chemNickelCad,
    chemNickelMetalHd, chemLithiumIon, chemZincAir, chemLithiumPolymer);

  T022_PortableBattery = packed record // v2.1+
    Header: TSMStructHeader; // v2.1+
    _Location, _Manufacturer, _ManufactureDate, // v2.1+
      _SerialNumber, _DeviceName: IDStr; // v2.1+
    DeviceChemistry: TDeviceChemistry; // v2.1+
    DesignCapacity, DesignVoltage: word; // v2.1+
    _SBDSVersionNumber: IDStr; // v2.1+
    MaxErrorInBatteryData: byte; // v2.1+
    SBDSSerialNumber, SBSDSManufactureDate: word; // v2.2+
    _SBDSDeviceChemistry: IDStr; // v2.2+
    DesignCapacityMultiplier: byte; // v2.2+
    OEMDefinedInfo: word; // v2.2+
  end;

  TResetStatus = (rstReserved, rstOperatingSystem, rstSystemUtilities, rstDontReboot);
  TGenericStatus = (gstDisabled, gstEnabled, gstNotImplemented, gstUnknown);

  T023_SystemReset = packed record // v2.2+
    Header: TSMStructHeader;
    Capabilities: byte;
    ResetCount, ResetLimit, TimerInterval, TimeOut: word;
  end;

  _THWPasswordStatus = (paswdResetEnabled, paswdReset_NotImplemented,
    paswdAdminEnabled, paswdAdmin_NotImplemented, paswdKeyboardEnabled,
    paswdKeyboard_NotImplemented, paswdPowerOnEnabled, paswdPowerOn_NotImplemented);

  THWSecuritySettings = set of _THWPasswordStatus;

  T024_HardwareSecurity = packed record // v2.2+
    Header: TSMStructHeader;
    HWSecuritySettings: THWSecuritySettings;
  end;

  T025_SystemPowerControl = packed record // v2.2+
    Header: TSMStructHeader;
    nextSchedPowerOnMonth, nextSchedPowerOnDayOfMonth, nextSchedPowerOnHour,
      nextSchedPowerOnMinute, nextSchedPowerOnSecond: byte;
  end;

  TDeviceStatus = (devstInvalid, staOther, devstUnknown, devstOK,
    devstNonCritical, devstCritical, devstNonRecoverable);

  TProbeLocation = (gplkInvalid, gplkOther, gplkUnknown, gplkProcessor,
    gplkDisk, gplkPeriphralBay, gplkSysMgtModule, gplkMotherBoard, gplkMemoryModule,
    gplkProcessorModule, gplkPowerUnit, gplkAddInCard, gplkFrontPanel, gplkBackPanel,
    gplkPowerSystem, gplkDriveBackPlane);

  T000_DeviceProbe = packed record // v2.2+
    Header: TSMStructHeader;
    _Description: IDStr;
    LocationAndStatus: byte; // bit[0..4]:TProbeLocation, bit[5..7]:TDeviceStatus
    MaxValue, MinValue, Resolution, Tolerance, Accuracy: word;
    OEMDefinedInfo: dword;
    NominalValue: word;
  end;

  T026_VoltageProbe = T000_DeviceProbe; // v2.2+

  TCoolingDevice = (coolInvalid, coolOther, coolUnknown, coolFan, coolCentrifugalBlower,
    coolChipFan, coolCabinetFan, coolPowerSupplyFan, coolHeatPipe, coolIntegratedRefrg,
    coolActiveCooling, coolPassiveCooling);

  T027_CoolingDevice = packed record // v2.2+
    Header: TSMStructHeader;
    hTemperatureProbe: word;
    DeviceTypeAndStatus: byte; // bit[0..4]:TCoolingDevice, bit[5..7]:TDeviceStatus
    CoolingUnitGroup: byte;
    OEMDefinedInfo: dword;
    NominalSpeed: word;
  end;

  T028_TemperatureProbe = T000_DeviceProbe; // v2.2+

  T029_ElectricalCurrentProbe = T000_DeviceProbe; // v2.2+

  _TConnection = (cnctInbound, cnctOutbound, cnctReservedTo07);
  TConnections = set of _TConnection;

  T030_OutOfBandRemoteAccess = packed record // v2.2+
    Header: TSMStructHeader;
    _ManufacturerName: IDStr;
    Connections: TConnections;
  end;

  T031_BootIntegrityServicesEntryPoint = packed record // v2.3+
    Header: TSMStructHeader;
    DATA: packed record end;
  end;

  TSystemBootStatus = (sbsOK, sbsNoBoot, sbsOSLoadFailure, sbsUnknowFailure, sbsHWFailure,
    sbsUserBoot, sbsSecurityViolation, sbsPrevBootImage, sbsTimerExpired, sbsReservedTo7Fh);

  T032_SystemBootInfo = packed record // v2.3+
    Header: TSMStructHeader;
    Reserved: packed array[0..5] of byte;
    BootStatus: packed array[0..0] of TSystemBootStatus;
  end;

  T033_64BitMemoryErrorInfo = packed record // v2.3+
    Header: TSMStructHeader;
    ErrorType: TMemoryError;
    ErrorGranularity: TMemoryErrorGranularity;
    ErrorOperation: TMemoryErrorOperation;
    VendorSyndrome: dword;
    MemoryArrayErrorAddress, DeviceErrorAddress: qword;
    ErrorResolution: dword;
  end;

  TManagementDevice = (mgdInvalid, mgdOther, mgdUnknown, mgdNSLM75, mgdNSLM78,
    mgdNSLM79, mgdNSLM80, mgdNSLM81, mgdADM9240, mgdDS1780, mgdMaxim1617,
    mgdGL518SM, mgdW83781D, mgdHT82H791);

  TManagementDeviceAddress = (mgaInvalid, mgamgaOther, mgaUnknown, mgaIOPort,
    mgaMemory, mgaSMBus);

  T034_ManagementDeviceInfo = packed record // v2.3+
    Header: TSMStructHeader;
    _Description: IDStr;
    DeviceType: TManagementDevice;
    Address: dword;
    AddresType: TManagementDeviceAddress;
  end;

  T035_MgtDeviceComponentInfo = packed record // v2.3+
    Header: TSMStructHeader;
    _Description: IDStr;
    hManagementDevice, hComponent, hTreshold: word;
  end;

  T036_MgtDeviceThresholdData = packed record // v2.3+
    Header: TSMStructHeader;
    NonCriticalLowerThr, NonCriticalUpperThr: word;
    CriticalLowerThr, CriticalUpperThr: word;
    NonRecoverableLowerThr, NonRecoverableUpperThr: word;
  end;

  TMemoryChannel = (mcnlInvalid, mcnlOther, mcnlUnknown, mcnlRamBus, mcnlSyncLink);

  T037_MemoryChannelInfo = packed record // v2.3+
    Header: TSMStructHeader;
    ChannelType: TMemoryChannel;
    MaxChannelLoad, MemDeviceCount: byte;
    List: array[0..0] of packed record
      MemDeviceLoad: byte;
      hMemDevice: word;
    end;
  end;

  TBMCInterface = (bmcifUnknown, bmcifKCS, bmcifSMIC, bmcifBT, bmcifReservedToFFh);

  T038_IPMIDeviceInfo = packed record
    Header: TSMStructHeader;
    InterfaceType: TBMCInterface;
    IPMISpecRevision: byte;
    I2CSlaveAddress, NVStorageDeviceAddress: byte;
    BaseAddress: qword;
  end;

  //PowerSupply Characteristics bit fields
  TDMTFPowerSupply = (pwrsInvalid, pwrsOther, pwrsUnknown, pwrsLinear, pwrsSwitching,
    pwrsBattery, pwrsUPS, pwrsConverter, pwrsRegulator, pwrsReservedTo0Fh);
  TDMTFStatus = TDeviceStatus;
  TDMTFInputVoltageRangeSwitching = (ivrsInvalid, ivrsOther, ivrsUnknown, ivrsManual,
    ivrsAutoSwitch, ivrsWideRange, ivrsNotApplicable, ivrsReservedTo0Fh);

  T039_ = packed record
    Header: TSMStructHeader;
    PowerUnitGroup: byte;
    _Location, _DeviceName, _Manufacturer: IDStr;
    _SerialNumber, _AssetTag, _ModelPart, _RevisionLevel: IDStr;
    MaxPowerCapacity, PowerSupplyCharacteristics: word;
    hInputVoltageProbe, hCoolingDevice, hInputCurrentProbe: word;
  end;
  T126_Inactive = packed record // v2.2+
    Header: TSMStructHeader;
  end;
  T127_EndOfTable = packed record // v2.2+
    Header: TSMStructHeader;
  end;
implementation
const
{$I CProcessors.inc}
  BIOSCharacteristics: array[_TBIOSCharacteristic] of string = (
    'Reserved',
    'Reserved',
    'Unknown',
    'BIOS Characteristics Not Supported',
    'ISA is supported',
    'MCA is supported',
    'EISA is supported',
    'PCI is supported',
    'PC Card (PCMCIA) is supported',
    'Plug and Play is supported',
    'APM is supported',
    'BIOS is Upgradeable (Flash)',
    'BIOS shadowing is allowed',
    'VL-VESA is supported',
    'ESCD support is available',
    'Boot from CD is supported',
    'Selectable Boot is supported',
    'BIOS ROM is socketed',
    'Boot From PC Card (PCMCIA) is supported',
    'EDD (Enhanced Disk Drive) Specification is supported',
    'INT 13h, Japanese Floppy for NEC 9800 1.2Mb (3.5", 1KB/Sector, 360 RPM) is supported',
    'INT 13h, Japanese Floppy for Toshiba 1.2Mb (3.5", 360 RPM) is supported',
    'INT 13h, 5.25", 360KB Floppy Services are supported',
    'INT 13h, 5.25", 1.44MB Floppy Services are supported',
    'INT 13h, 3.5", 720KB Floppy Services are supported',
    'INT 13h, 3.5", 2.88MB Floppy Services are supported',
    'INT 05h, Print Screen Service is supported',
    'INT 09h, 8042 Keyboard services are supported',
    'INT 14h, Serial Services are supported',
    'INT 17h, Printer Services are supported',
    'INT 10h, CGA/Mono Video Services are supported',
    'NEC PC-98');
  //'Reserved for BIOS Vendor',
  //'Reserved for System Vendor');

  BIOSCharacteristicsExt1: array[_TBIOSCharacteristicExt1] of string = (
    'ACPI supported',
    'USB Legacy is supported',
    'AGP is supported',
    'I2O boot is supported',
    'LS-120 boot is supported',
    'ATAPI ZIP Drive boot is supported',
    '1394 boot is supported',
    'Smart Battery supported');

procedure fillProcessorsDesc;
var
  p: TProcessorFamily;
begin
  for p := low(p) to high(p) do begin
    //s := pChar(ProcessorsFamily[p]);
    //if s = '' then
    if length(ProcessorsFamily[p]) = 0 then
      //StrPCopy(ProcessorsFamily[p], 'Unassigned');
      ProcessorsFamily[p] := 'Unassigned';
  end;
end;

initialization
  fillProcessorsDesc;

end.

