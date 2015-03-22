//
//  InboxViewCell.h
//  Ribbit
//
//  Created by Sarp Oğulcan Solakoğlu on 22/03/15.
//  Copyright (c) 2015 esoes. All rights reserved.
//

@import UIKit;
#import "CEReactiveView.h"
//CEReactiveView is a helper class written by Colin Eberhardt and used in the Ray Wanderlich MVVM
//tutorial. It is a binding method for TableViews with ReactiveCocoa. Code is in the Utils group.
@interface InboxViewCell : UITableViewCell <CEReactiveView>

@end
