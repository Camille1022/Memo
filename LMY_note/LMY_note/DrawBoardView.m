//
//  DrawBoardView.m
//  LMY_note
//
//  Created by sq-ios81 on 16/5/4.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import "DrawBoardView.h"
#import "PathStyle.h"

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface DrawBoardView()
{
    CGPoint firstPoint;
    CGPoint middlePoint;
    CGPoint lastPoint;
    
    BOOL onDraw;
    
    UIBarButtonItem *okItem;
    UIBarButtonItem *cancelItem;
}

@property (nonatomic, strong) UIToolbar *toolBar;

@property (nonatomic ,strong)NSMutableArray * paths;
@property (nonatomic, strong) NSMutableArray* pathStyle;

@property (nonatomic, strong) PathStyle* currentPathStyle;
@property (nonatomic, strong) UIBezierPath* currentPath;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, strong) UIColor* currentColor;
@property (nonatomic, assign) CGFloat currentWidth;

@property (nonatomic, assign) PrintStyle printStyle;
@property (nonatomic, assign) DrawStyle drawStyle;

@end

@implementation DrawBoardView


-(NSMutableArray *)paths {
    if (_paths == nil)
        _paths = [NSMutableArray array];
    return _paths;
}
-(NSMutableArray *)pathStyle {
    if (!_pathStyle)
        _pathStyle = [NSMutableArray array];
    return _pathStyle;
}

- (void)didMoveToSuperview {
    // items 初始化
    okItem = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStylePlain target:self action:@selector(okClicked)];
    okItem.tintColor = [UIColor darkGrayColor];
    okItem.enabled = NO;
    
    cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked)];
    cancelItem.tintColor = [UIColor darkGrayColor];
    cancelItem.enabled = NO;
    // item 直接的间距
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    self.toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, HEIGHT-252, WIDTH - 50, 44)];
    self.toolBar.items = [NSArray arrayWithObjects:fixed,cancelItem,fixed,okItem,fixed, nil];
    self.toolBar.barStyle = UIBarStyleDefault;
    [self addSubview:self.toolBar];
    
    [self getNotification];
}

-(void)okClicked {
    UIBezierPath* path = [UIBezierPath bezierPath];
    switch (_drawStyle) {
        case DrawStyleLine:
            path = [self drawLine];
            break;
        case DrawStyleCircle:
            path = [self drawCircle];
            break;
        case DrawStyleRectangle:
            path = [self drawRectangle];
            break;
        default:
            break;
    };
    
    [_paths addObject:path];
    [_pathStyle addObject:_currentPathStyle];
    
    [self cancelClicked];
}
-(void)cancelClicked {
    onDraw = 0;
    
    firstPoint  = CGPointZero;
    middlePoint = CGPointZero;
    lastPoint   = CGPointZero;
    
    [self setNeedsDisplay];
}

#pragma mark - Response Notification 
-(void)getNotification {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearBoard) name:@"clearBoard" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(revokeBoard) name:@"revokeBoard" object:nil];
}
-(void)clearBoard {
    [self.paths removeAllObjects];
    [self.pathStyle removeAllObjects];
    [self setNeedsDisplay];
}
-(void)revokeBoard {
    [self.paths removeLastObject];
    [self.pathStyle removeLastObject];
    [self setNeedsDisplay];
}

#pragma mark - Get Touch Events
-(void)getPathStyle {
    [self getCurrentColor:[[NSUserDefaults standardUserDefaults]objectForKey:@"lineColor"]];
    _currentWidth = [[[NSUserDefaults standardUserDefaults]objectForKey:@"lineWidth"] intValue];
    NSString *tag = [[NSUserDefaults standardUserDefaults]objectForKey:@"styleTag"];
    _drawStyle = tag.integerValue;
    _printStyle = PrintStyleStrock;
}
-(void)getCurrentColor:(NSString *)colorStr {
    NSArray *arr = [colorStr componentsSeparatedByString:@" "];
    
    CGFloat redColor   = [arr[1] floatValue];
    CGFloat greenColor = [arr[2] floatValue];
    CGFloat blueColor  = [arr[3] floatValue];
    CGFloat alphaColor = [arr[4] floatValue];
    
    _currentColor = [UIColor colorWithRed:redColor green:greenColor blue:blueColor alpha:alphaColor];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSNotification *notif = [NSNotification notificationWithName:@"colorDismiss" object:nil];
    [[NSNotificationCenter defaultCenter]postNotification:notif];
    
    // get current point
    _currentPoint = [touches.anyObject locationInView:self];
    
    //creat path
    UIBezierPath* path = [UIBezierPath bezierPath];
    [self.paths addObject:path];
    _currentPath = path;
    
    // get style
    [self getPathStyle];
    if (_drawStyle == 0 || _drawStyle == 4) {
        okItem.enabled = NO;
        cancelItem.enabled = NO;
    } else {
        okItem.enabled = YES;
        cancelItem.enabled = YES;
    }
    
    // rubber
    if (_drawStyle == DrawStyleRubber)
        _currentColor = self.backgroundColor;
    
    //style
    _currentPathStyle = [PathStyle new];
    _currentPathStyle.lineColor = _currentColor;
    _currentPathStyle.lineWidth = _currentWidth;
    _currentPathStyle.drawStyle = _drawStyle;
    _currentPathStyle.printStyle = _printStyle;
    [self.pathStyle addObject:_currentPathStyle];
    
    switch (_drawStyle) {
            //自由曲线
        case DrawStyleFreedomLine:
        case DrawStyleRubber:
            [self drawFreedomLineTouchBegin];
            break;
            //其他
        default:
            [self drawLineTouchBegin];
            break;
    }
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _currentPoint = [touches.anyObject locationInView:self];
    
    switch (_drawStyle) {
            //自由曲线
        case DrawStyleFreedomLine:
        case DrawStyleRubber:
            [self drawFreedomLineTouchMove];
            break;
            //直线 、矩形 、 圆
        case DrawStyleLine:
        case DrawStyleRectangle:
        case DrawStyleCircle:
            [self drawLineTouchMove];
            break;
        default:
            break;
    }
    
    [self setNeedsDisplay];
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (CGSizeEqualToSize(_currentPath.bounds.size, CGSizeZero)) {
        [_paths removeObject:_currentPath];
        [_pathStyle removeObjectAtIndex:_pathStyle.count - 1];
    }
    switch (_drawStyle) {
        case DrawStyleFreedomLine:
        case DrawStyleRubber:
            break;
        default:
            [self drawLineTouchMove];
            break;
    }
}

- (void)drawRect:(CGRect)rect {
    for (int i = 0; i < self.paths.count; i++) {
        UIBezierPath* path = _paths[i];
        PathStyle* style = _pathStyle[i];
        //设置style
        [path setLineWidth:style.lineWidth];
        [style.lineColor setStroke];
        //美化
        [path setLineCapStyle:kCGLineCapRound];
        [path setLineJoinStyle:kCGLineJoinRound];
        //渲染
        if (style.printStyle == PrintStyleStrock) {
            [path stroke];
        } else {
            [path fill];
        }
    }
    switch (_drawStyle) {
        case DrawStyleLine:
            [self drawLinePath];
            break;
        case DrawStyleCircle:
            [self drawCirclePath];
            break;
        case DrawStyleRectangle:
            [self drawRectanglePath];
            break;
        default:
            break;
    }
}

#pragma mark - Draw Style
#pragma mark     free line
//自由线-----开始触摸
- (void)drawFreedomLineTouchBegin {
    [_currentPath moveToPoint:_currentPoint];
}
//自由线-----移动
- (void)drawFreedomLineTouchMove {
    UIBezierPath* path = _currentPath;
    [path addLineToPoint:_currentPoint];
}

#pragma mark   line
-(void)drawLineTouchBegin {
    firstPoint = _currentPoint;
}
-(void)drawLineTouchMove {
    lastPoint = _currentPoint;
}
- (UIBezierPath*)drawLine {
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:firstPoint];
    [path addLineToPoint:lastPoint];
    return path;
}
- (void)drawLinePath {
    UIBezierPath* cir1 = [UIBezierPath bezierPathWithArcCenter:firstPoint radius:5 startAngle:0 endAngle:2 * M_PI clockwise:1];
    [cir1 fill];
    UIBezierPath* cir2 = [UIBezierPath bezierPathWithArcCenter:lastPoint radius:5 startAngle:0 endAngle:2 * M_PI clockwise:1];
    [cir2 fill];
    [[self drawLine] stroke];
}

#pragma mark    rectangle
- (UIBezierPath*)drawRectangle {
    CGRect rect = CGRectMake(firstPoint.x, firstPoint.y, lastPoint.x - firstPoint.x, lastPoint.y - firstPoint.y);
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:rect];
    return path;
}
- (void)drawRectanglePath {
    UIBezierPath* cir1 = [UIBezierPath bezierPathWithArcCenter:firstPoint radius:5 startAngle:0 endAngle:2 * M_PI clockwise:1];
    [cir1 fill];
    UIBezierPath* cir2 = [UIBezierPath bezierPathWithArcCenter:lastPoint radius:5 startAngle:0 endAngle:2 * M_PI clockwise:1];
    [cir2 fill];
    [[self drawRectangle] stroke];
}

#pragma mark    circle
- (UIBezierPath*)drawCircle {
    CGFloat radius = sqrt(pow((firstPoint.x - lastPoint.x), 2) + pow((firstPoint.y - lastPoint.y), 2));
    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:firstPoint radius:radius startAngle:0 endAngle:2 * M_PI clockwise:1];
    return path;
}
- (void)drawCirclePath {
    UIBezierPath* cir1 = [UIBezierPath bezierPathWithArcCenter:firstPoint radius:5 startAngle:0 endAngle:2 * M_PI clockwise:1];
    [cir1 fill];
    UIBezierPath* cir2 = [UIBezierPath bezierPathWithArcCenter:lastPoint radius:5 startAngle:0 endAngle:2 * M_PI clockwise:1];
    [cir2 fill];
    UIBezierPath* line = [UIBezierPath bezierPath];
    [line moveToPoint:firstPoint];
    [line addLineToPoint:lastPoint];
    [line stroke];
    
    [[self drawCircle] stroke];
}

@end
