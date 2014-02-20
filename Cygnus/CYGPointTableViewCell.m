//
//  CYGPointTableViewCell.m
//  Cygnus
//
//  Created by IO on 2/19/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGPointTableViewCell.h"
#import "CYGPoint.h"
#import "CYGManager.h"

static NSNumberFormatter *_numberFormatter = nil;
static NSDateFormatter *_dateFormatter = nil;

@interface CYGPointTableViewCell ()

@end

@implementation CYGPointTableViewCell

+ (NSNumberFormatter *)numberFormatter
{
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter.locale = [NSLocale currentLocale];
        _numberFormatter.maximumFractionDigits = 2;
    }
    return _numberFormatter;
}

+ (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    return _dateFormatter;
}

- (NSString *)convertDistanceToString:(double)distance
{
    BOOL isMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
    
    NSString *format;
    
    if (isMetric) {
        if (distance < kCYGMetersCutoff) {
            format = @"%@ m";
        } else {
            format = @"%@ km";
            distance = distance / 1000;
        }
    } else {
        distance = distance * kCYGMetersToFeet;
        if (distance < kCYGFeetCutoff) {
            format = @"%@ ft";
        } else {
            format = @"%@ mi";
            distance = distance / kCYGMilesToFeet;
        }
    }
    return [NSString stringWithFormat:format, [[CYGPointTableViewCell numberFormatter] stringFromNumber:@(distance)]];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.distanceLabel.text = @"...";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.tagsLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.tagsLabel.frame);
}

- (void)setPoint:(CYGPoint *)point
{
    _point = point;
    self.titleLabel.text = (point.title) ?: [[CYGPointTableViewCell dateFormatter] stringFromDate:_point.createdAt];
    self.tagsLabel.text = [point.tags componentsJoinedByString:@","];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:_point.location.latitude longitude:_point.location.longitude];
    self.distanceLabel.text = [self convertDistanceToString:[location distanceFromLocation:[[CYGManager sharedManager] currentLocation]]];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _titleLabel = [UILabel autoLayoutView];
        [self.contentView addSubview:_titleLabel];
        [_titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [_titleLabel setNumberOfLines:1];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setTextColor:[UIColor darkGrayColor]];

        _tagsLabel = [UILabel autoLayoutView];
        [self.contentView addSubview:_tagsLabel];
        [_tagsLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [_tagsLabel setNumberOfLines:0];
        [_tagsLabel setTextAlignment:NSTextAlignmentLeft];
        [_tagsLabel setTextColor:[UIColor lightGrayColor]];
        
        _distanceLabel = [UILabel autoLayoutView];
        [self.contentView addSubview:_distanceLabel];
        [_distanceLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [_distanceLabel setNumberOfLines:1];
        [_distanceLabel setTextAlignment:NSTextAlignmentLeft];
        [_distanceLabel setTextColor:[UIColor lightGrayColor]];
        
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _tagsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _distanceLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        
        
        // Constraints
        
        // Note: if the constraints you add below require a larger cell size than the current size (which is likely to be the default size {320, 44}), you'll get an exception.
        // As a fix, you can temporarily increase the size of the cell's contentView so that this does not occur using code similar to the line below.
        // Further discussion: https://github.com/Alex311/TableCellWithAutoLayout/commit/bde387b27e33605eeac3465475d2f2ff9775f163#commitcomment-4633188
        // self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);
        [_titleLabel pinEdges:(FTUIViewEdgePinTop | FTUIViewEdgePinLeft | FTUIViewEdgePinRight) toSuperViewWithInset:16];
        
        [_tagsLabel pinEdges:(FTUIViewEdgePinLeft) toSuperViewWithInset:16];
        [_tagsLabel pinEdge:FTUIViewEdgePinTop toEdge:FTUIViewEdgePinBottom ofItem:_titleLabel inset:3];
        
        [_distanceLabel pinEdges:(FTUIViewEdgePinLeft | FTUIViewEdgePinBottom) toSuperViewWithInset:16];
        [_distanceLabel pinEdge:FTUIViewEdgePinTop toEdge:FTUIViewEdgePinBottom ofItem:_tagsLabel inset:3];
        
        // Initialization
        
        self.distanceLabel.text = @"...";
    }
    return self;
}

- (NSString *)reuseIdentifier
{
    return kCYGPointTableViewCellId;
}

@end
