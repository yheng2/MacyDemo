//
//  ViewController.m
//  MacyDemo
//
//  Created by Yiwei Heng on 5/5/16.
//  Copyright © 2016 Yiwei Heng. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "MBProgressHUD.h"

@interface ViewController ()

#define baseURL @"http://www.nactem.ac.uk/software/acromine/"

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* acronymList;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _searchBar.delegate = self;
    _acronymList = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleRequest{
    
    [self.view endEditing:YES];

    // Show HUD indicator
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Format the path
    NSString* path = [NSString stringWithFormat:@"dictionary.py?sf=%@",_searchBar.text];
    NSString* targetPath = [NSString stringWithFormat:@"%@%@",baseURL,path];
    
    NSURL *URL = [NSURL URLWithString:targetPath];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if([responseObject count]!=0){
            _acronymList = [[responseObject objectAtIndex:0] objectForKey:@"lfs" ];

            dispatch_async(dispatch_get_main_queue(), ^{

                [_tableView reloadData];
            });
        }
        else{
            [self showAlert:nil Freq:nil];
        
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

// It is important for you to hide the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_acronymList count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.textLabel.text = [_acronymList[indexPath.row] objectForKey:@"lf"];
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id year = [_acronymList[indexPath.row] objectForKey:@"since"];
    id freq = [_acronymList[indexPath.row] objectForKey:@"freq"];
    
    [self showAlert:year Freq:freq];
    
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self handleRequest];
    [searchBar resignFirstResponder];
}

- (void)showAlert:(NSString*)year Freq:(NSString*)freq{
    
    if(year){
    
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Freq: %@",freq] message:[NSString stringWithFormat:@"Since: %@",year] preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:^{
        
        }];
    }
    else{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Search Result" message:@"Sorry, found nothing..." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
        
    }
    
    
}

@end
