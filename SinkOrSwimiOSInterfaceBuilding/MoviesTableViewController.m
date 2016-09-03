#import <UIImageView+AFNetworking.h>
#import <JLTMDbClient.h>
#import "MoviesTableViewController.h"
#import "MovieDetailsViewController.h"

@interface MoviesTableViewController ()


@end

@implementation MoviesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfiguration];
    self.tableView.rowHeight = 60.0f;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.moviesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MovieCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    NSDictionary *movieDict = self.moviesArray[indexPath.row];
    cell.textLabel.text = movieDict[@"original_title"];
    cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (movieDict[@"poster_path"] != [NSNull null]) {
        NSString *imageUrl = [self.imagesBaseUrlString stringByAppendingString:movieDict[@"poster_path"]];
        [cell.imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"TMDB"]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MovieDetailsViewController *movieDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MovieDetailsViewController"];
    movieDetailViewController.movieId = self.moviesArray[indexPath.row][@"id"];
    movieDetailViewController.movieTitle = self.moviesArray[indexPath.row][@"title"];
    movieDetailViewController.imagesBaseUrlString = self.imagesBaseUrlString;
    [self.navigationController pushViewController:movieDetailViewController animated:YES];
}

#pragma mark - Private Methods

- (void) loadConfiguration {
    __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbConfiguration withParameters:nil andResponseBlock:^(id response, NSError *error) {
        if (!error)
            self.imagesBaseUrlString = [response[@"images"][@"base_url"] stringByAppendingString:@"w92"];
        else
            [errorAlertView show];
    }];
}



- (void) refresh {
    NSArray *optionsArray = @[kJLTMDbMoviePopular, kJLTMDbMovieUpcoming, kJLTMDbMovieTopRated];
    __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    
    NSString* option = optionsArray[self.categoryCounter];
    self.categoryCounter++;
    
    if(self.categoryCounter == 3){
        self.categoryCounter = 0;
    }
    
    if(option == kJLTMDbMoviePopular){
        self.mainNavItem.title = @"Popular Movies";
    }else if(option == kJLTMDbMovieUpcoming){
        self.mainNavItem.title = @"Upcoming Movies";
    }else if(option == kJLTMDbMovieTopRated){
        self.mainNavItem.title = @"Top Rated Movies";
    }else{
        self.mainNavItem.title = @"Movies";
    }
    
    [[JLTMDbClient sharedAPIInstance] GET:option withParameters:nil andResponseBlock:^(id response, NSError *error) {
        if (!error) {
            self.moviesArray = response[@"results"];
            [self.tableView reloadData];
        }else
            [errorAlertView show];
        [self.refreshControl endRefreshing];
    }];
}

@end
