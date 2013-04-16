//
// Created by rts on 07/04/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import "AVPhotoController.h"
#import "AVPhotoView.h"

@interface AVPhotoController () <UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *imagePaths;
@property (nonatomic, strong) NSMutableArray *photoViews;
@end

@implementation AVPhotoController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if(self)
    {
        self.delegate = self;
        self.pagingEnabled = YES;
        self.photoViews = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void) loadImagePaths:(NSArray*)paths
{
    self.imagePaths = paths;

    if(self.imagePaths.count > 0)
        [self setupScrollView];
}

- (void) setupScrollView
{
    // Reset all stuff
    [self.photoViews enumerateObjectsUsingBlock:^(AVPhotoView *obj, NSUInteger idx, BOOL *stop) {
        [obj unloadImage];
        [obj removeFromSuperview];
    }];

    [self.photoViews removeAllObjects];

    // Create new frame for photos
    CGRect photoFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGFloat photoWith = photoFrame.size.width;

    for(NSString *path in self.imagePaths)
    {
        NSLog(@"PhotoFrame: %@", NSStringFromCGRect(photoFrame));

        // Create the photo and add it to view
        AVPhotoView *photo = [[AVPhotoView  alloc] initWithFrame:photoFrame];
        photo.imagePath = path;
        [self addSubview:photo];

        // Save if for later user
        [self.photoViews addObject:photo];

        // Add with to origin for next image
        photoFrame.origin.x += photoWith;
    }

    // Set the total contentsize
    self.contentSize = CGSizeMake((photoWith * self.photoViews.count), photoFrame.size.height);

    NSLog(@"My own size: %@", NSStringFromCGRect(self.frame));
    NSLog(@"Content size: %@", NSStringFromCGSize(self.contentSize));

    [self scrollViewDidEndDecelerating:self];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    int nextPage = currentPage + 1;
    int prevPage = currentPage - 1;

    // Load current page
    AVPhotoView *currentPhoto = [self.photoViews objectAtIndex:currentPage];
    [currentPhoto loadImage];

    // Load next page
    if(nextPage < self.photoViews.count)
    {
        AVPhotoView *photo = [self.photoViews objectAtIndex:nextPage];
        [photo loadImage];
    }

    // Unload pages not needed
    [self.photoViews enumerateObjectsUsingBlock:^(AVPhotoView *obj, NSUInteger idx, BOOL *stop) {

        if(idx != currentPage || idx != nextPage && idx != prevPage)
        {
            //NSLog(@"Unload image");
            //[obj unloadImage];
        }
    }];
}

@end