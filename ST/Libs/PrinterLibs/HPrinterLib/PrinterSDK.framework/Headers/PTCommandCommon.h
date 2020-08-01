/*!
 *  \~chinese
 *  @header PTCommandCommon.h
 *  @abstract 公共指令
 *
 *  \~english
 *  @header PTCommandCommon.h
 *  @abstract Common Command
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PTCommandCommon : NSObject

@property(nonatomic, strong) NSMutableData * _Nonnull cmdData;

/// 获取打印机型号,回的数据格式：51333142 5400
- (void)getPrinterModelName;

/// 获取打印机固件版本号,版本号返回格式为 X.XX.XX或X.X.X【如1.01.01或1.0.3】
- (void)getPrinterFirmwareVersion;

/// OTA蓝牙固件升级,该功能需要打印机支持
- (void)updateOTABleFirmwareWithData:(NSData *)data;


@end

NS_ASSUME_NONNULL_END
