UINT64 DcBase = 0;
UINT64 GpioValBase = 0;
UINT64 GpioDirBase = 0;


#define LOW            (0)
#define HIGH           (1)
#define DVO_CH0        (0)
#define DVO_CH1        (1)
#define DVO_0_SDA      (0)
#define DVO_0_SCL      (1)
#define DVO_1_SDA      (2)
#define DVO_1_SCL      (3)
#define GPIO_DIR_OUT   (0)
#define GPIO_DIR_IN    (1)

/////////////////////////////////////////////////////////////////////////////
#define I2C_KHZ         (200)
#define I2C_DELAY       (gBS->Stall((1000000/(I2C_KHZ*1000)/2)))
#define I2C_DELAY_HAlF  (gBS->Stall((1000000/(I2C_KHZ*1000)/4)))

////////////////////////////////////////////////////////////////////////////////
#define SDA_SET_HIGHT(GPIO_SDA)   (SetGpioValue(GPIO_SDA, HIGH))
#define SDA_SET_LOW(GPIO_SDA)     (SetGpioValue(GPIO_SDA, LOW))
#define SDA_SET_OUT(GPIO_SDA)     (SetGpioDirection(GPIO_SDA, GPIO_DIR_OUT))
#define SDA_SET_IN(GPIO_SDA)      (SetGpioDirection(GPIO_SDA, GPIO_DIR_IN))
#define SDA_GET_VAL(GPIO_SDA)     (GetGpioValue(GPIO_SDA))

#define SCL_SET_HIGHT(GPIO_SCL)   (SetGpioValue(GPIO_SCL, HIGH))
#define SCL_SET_LOW(GPIO_SCL)     (SetGpioValue(GPIO_SCL, LOW))
#define SCL_SET_OUT(GPIO_SCL)     (SetGpioDirection(GPIO_SCL, GPIO_DIR_OUT))
#define SCL_SET_IN(GPIO_SCL)      (SetGpioDirection(GPIO_SCL, GPIO_DIR_IN))
#define SCL_GET_VAL(GPIO_SCL)     (GetGpioValue(GPIO_SCL))


#define DVO_CH_SELECT_CODE(DVO_CH,SCL,SDA)  \
	if(DVO_CH == DVO_CH0){            \
		SCL = DVO_0_SCL; SDA = DVO_0_SDA;   \
	}else if(DVO_CH == DVO_CH1){      \
		SCL = DVO_1_SCL; SDA = DVO_1_SDA;   \
	}


VOID I2CSend_Data(UINT8 DvoCh, UINT8 DevAddr,UINT8 RegAddr,UINT8 Data);
VOID I2CSend_Data_Block(UINT8 DvoCh, UINT8 DevAddr,UINT8 *Data,UINT8 Size);
UINT8 I2CReceive_Data(UINT8 DvoCh, UINT8 DevAddr,UINT8 RegAddr);
VOID I2CReceive_Data_Block(UINT8 DvoCh, UINT8 DevAddr, UINT8 RegAddr, UINT8 *RecvDate, UINT8 Size);

/**I2CStart**/
VOID I2CStart(UINT8 DvoCh)
{

	UINT8 SCL = 0, SDA = 0;
	DVO_CH_SELECT_CODE(DvoCh,SCL,SDA);

	SDA_SET_OUT(SDA);
	SCL_SET_OUT(SCL);
	I2C_DELAY;

	SCL_SET_HIGHT(SCL);
	SDA_SET_HIGHT(SDA);
	I2C_DELAY;

	SDA_SET_LOW(SDA);
	I2C_DELAY;

	SCL_SET_LOW(SCL);
}


/**I2CSendByte**/
VOID I2CSendByte(UINT8 DvoCh, UINT8 Data)
{
	UINT8 i;
	UINT8 SCL = 0, SDA = 0;
	DVO_CH_SELECT_CODE(DvoCh,SCL,SDA);

	SDA_SET_OUT(SDA);

	for(i=0; i<8; i++){
		I2C_DELAY_HAlF;
		if((Data >> 7) & 0x01){
			SDA_SET_HIGHT(SDA);
		}else{
			SDA_SET_LOW(SDA);
		}
		I2C_DELAY_HAlF;

		SCL_SET_HIGHT(SCL);
		I2C_DELAY;

		Data <<= 1;
		SCL_SET_LOW(SCL);
	}
}

/**I2CReceiveACK**/
VOID I2CReceiveACK(UINT8 DvoCh)
{
	UINT8 Val,i;
	UINT8 SCL = 0, SDA = 0;
	DVO_CH_SELECT_CODE(DvoCh,SCL,SDA);

	SDA_SET_IN(SDA);
	I2C_DELAY;

	SCL_SET_HIGHT(SCL);
	for(i=0; i < 3; i++){
		I2C_DELAY_HAlF;
		Val = SDA_GET_VAL(SDA);
		if(!Val){
			break;
		}
		I2C_DELAY_HAlF;
	}
	SCL_SET_LOW(SCL);
}

/**I2CStop**/
VOID I2CStop(UINT8 DvoCh)
{
	UINT8 SCL = 0, SDA = 0;
	DVO_CH_SELECT_CODE(DvoCh,SCL,SDA);

	SDA_SET_OUT(SDA);

	SDA_SET_LOW(SDA);
	I2C_DELAY;

	SCL_SET_HIGHT(SCL);
	I2C_DELAY_HAlF;
	
	SDA_SET_HIGHT(SDA);
}

/**I2CReceiveByte**/
UINT8 I2CReceiveByte(UINT8 DvoCh)
{
	UINT8 i;
	UINT8 Data = 0;
	UINT8 SCL = 0, SDA = 0;
	DVO_CH_SELECT_CODE(DvoCh,SCL,SDA);

	SDA_SET_IN(SDA);	

	for(i = 0;i < 8;i++){
		I2C_DELAY;
		SCL_SET_HIGHT(SCL);

		I2C_DELAY_HAlF;
		Data = ((Data << 1) | SDA_GET_VAL(SDA));

		I2C_DELAY_HAlF;
		SCL_SET_LOW(SCL);
	}
	return(Data);
}

/**I2CSendACK**/
VOID I2CSendACK(UINT8 DvoCh)
{
	UINT8 SCL = 0,SDA = 0;
	DVO_CH_SELECT_CODE(DvoCh,SCL,SDA);

	SDA_SET_OUT(SDA);

	I2C_DELAY_HAlF;
	SDA_SET_LOW(SDA);

	I2C_DELAY_HAlF;
	SCL_SET_HIGHT(SCL);

	I2C_DELAY;
	SCL_SET_LOW(SCL);
}

/**I2CSendNACK**/
VOID I2CSendNACK(UINT8 DvoCh)
{
	UINT8 SCL = 0, SDA = 0;
	DVO_CH_SELECT_CODE(DvoCh,SCL,SDA);

	SDA_SET_OUT(SDA);

	I2C_DELAY_HAlF;
	SDA_SET_HIGHT(SDA);

	I2C_DELAY_HAlF;
	SCL_SET_HIGHT(SCL);

	I2C_DELAY;
	SCL_SET_LOW(SCL);
}

VOID I2CSend_Data(UINT8 DvoCh, UINT8 DevAddr,UINT8 RegAddr,UINT8 Data)
{
	I2CStart(DvoCh);
	I2CSendByte(DvoCh, DevAddr);
	I2CReceiveACK(DvoCh);

	I2CSendByte(DvoCh, RegAddr);
	I2CReceiveACK(DvoCh);

	I2CSendByte(DvoCh,Data);
	I2CReceiveACK(DvoCh);

	I2CStop(DvoCh);
}

VOID I2CSend_Data_Block(UINT8 DvoCh, UINT8 DevAddr,UINT8 *Data,UINT8 Size)
{
	UINT8 Count;

	I2CStart(DvoCh);
	I2CSendByte(DvoCh, DevAddr);
	I2CReceiveACK(DvoCh);

	for(Count = 0;Count < Size; Count++){
		I2CSendByte(DvoCh, Data[Count]);
		I2CReceiveACK(DvoCh);
	}
	
	I2CStop(DvoCh);
}

UINT8 I2CReceive_Data(UINT8 DvoCh, UINT8 DevAddr,UINT8 RegAddr)
{
	UINT8 RecvDate;

	//启动送地址
	I2CStart(DvoCh);
	I2CSendByte(DvoCh,DevAddr);
	I2CReceiveACK(DvoCh);

	I2CSendByte(DvoCh, RegAddr);
	I2CReceiveACK(DvoCh);

	//启动改为读操作
	I2CStart(DvoCh);
	I2CSendByte(DvoCh, DevAddr| 0x01);
	I2CReceiveACK(DvoCh);

	RecvDate = I2CReceiveByte(DvoCh);
	I2CSendNACK(DvoCh);
	I2CStop(DvoCh);

	return RecvDate;
}

VOID I2CReceive_Data_Block(UINT8 DvoCh, UINT8 DevAddr, UINT8 RegAddr, UINT8 *RecvDate, UINT8 Size)
{
	UINT8 Count;
	
	I2CStart(DvoCh);
	I2CSendByte(DvoCh,DevAddr);
	I2CReceiveACK(DvoCh);
	
	I2CSendByte(DvoCh, RegAddr);
	I2CReceiveACK(DvoCh);

	I2CStart(DvoCh);
	I2CSendByte(DvoCh, DevAddr| 0x01);
	I2CReceiveACK(DvoCh);

	for(Count = 0;Count < Size; Count++){
		RecvDate[Count] = I2CReceiveByte(DvoCh);
		if(Count == Size -1){
			I2CSendNACK(DvoCh);
		}else{
			I2CSendACK(DvoCh);
		}
	}

	I2CStop(DvoCh);
}
