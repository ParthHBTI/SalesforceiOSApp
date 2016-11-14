// Copyright (c) 2011,2013 Jonathan Hersh, Simon Fell
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
// THE SOFTWARE.
//
// 
// Note: This file was generated by WSDL2ZKSforce. 
//		  see https://github.com/superfell/WSDL2ZKSforce
//       DO NOT HAND EDIT.
//

#import "ZKSforceClient+zkAsyncQuery.h"

@implementation ZKSforceClient (zkAsyncQuery)

-(BOOL)confirmLoggedIn {
	if (![self loggedIn]) {
		NSLog(@"ZKSforceClient does not have a valid session. request not executed");
		return NO;
	}
	return YES;
}


// This method implements the meat of all the perform* calls,
// it handles making the relevant call in any desired queue, 
// and then calling the fail or complete block on the UI thread.
//
-(void)performRequest:(id (^)())requestBlock
         checkSession:(BOOL)checkSession
            failBlock:(zkFailWithExceptionBlock)failBlock 
        completeBlock:(void (^)(id))completeBlock
                queue:(dispatch_queue_t)queue {

    if (!requestBlock) return;

    // sanity check that we're actually logged in and ready to go.
    if (checkSession && (![self confirmLoggedIn])) return;

    // run this block async on the desired queue
    dispatch_async(queue, ^{
        id result;
				
        @try {
            result = requestBlock();
        } @catch (NSException *ex) {
            // run the failBlock on the main thread.
            if (failBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failBlock(ex);
                });
            }

            return;
        }

        // run the completeBlock on the main thread.
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{            
                completeBlock(result);
            });
        }
    });
}

// Perform an asynchronous API call. 
// Defaults to the default background global queue.
//
-(void)performRequest:(id (^)())requestBlock
         checkSession:(BOOL)checkSession
            failBlock:(zkFailWithExceptionBlock)failBlock 
        completeBlock:(void (^)(id))completeBlock {

    [self performRequest:requestBlock
            checkSession:checkSession
               failBlock:failBlock
           completeBlock:completeBlock
                   queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)];
}

/** Login to the Salesforce.com SOAP Api */
-(void) performLogin:(NSString *)username password:(NSString *)password
           failBlock:(zkFailWithExceptionBlock)failBlock
       completeBlock:(zkCompleteLoginResultBlock)completeBlock {

	[self performRequest:^id {
			return [self login:username password:password];
		}
		 checkSession:NO
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKLoginResult *)r);
		}];
}

/** Describe an sObject */
-(void) performDescribeSObject:(NSString *)sObjectType
                     failBlock:(zkFailWithExceptionBlock)failBlock
                 completeBlock:(zkCompleteDescribeSObjectBlock)completeBlock {

	[self performRequest:^id {
			return [self describeSObject:sObjectType];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKDescribeSObject *)r);
		}];
}

/** Describe multiple sObjects (upto 100) */
-(void) performDescribeSObjects:(NSArray *)sObjectType
                      failBlock:(zkFailWithExceptionBlock)failBlock
                  completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self describeSObjects:sObjectType];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Describe the Global state */
-(void) performDescribeGlobalWithFailBlock:(zkFailWithExceptionBlock)failBlock
                completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self describeGlobal];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Describe all the data category groups available for a given set of types */
-(void) performDescribeDataCategoryGroups:(NSArray *)sObjectType
                                failBlock:(zkFailWithExceptionBlock)failBlock
                            completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self describeDataCategoryGroups:sObjectType];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Describe the data category group structures for a given set of pair of types and data category group name */
-(void) performDescribeDataCategoryGroupStructures:(NSArray *)pairs topCategoriesOnly:(BOOL)topCategoriesOnly
                                         failBlock:(zkFailWithExceptionBlock)failBlock
                                     completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self describeDataCategoryGroupStructures:pairs topCategoriesOnly:topCategoriesOnly];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Describes your Knowledge settings, such as if knowledgeEnabled is on or off, its default language and supported languages */
-(void) performDescribeKnowledgeSettingsWithFailBlock:(zkFailWithExceptionBlock)failBlock
                           completeBlock:(zkCompleteKnowledgeSettingsBlock)completeBlock {

	[self performRequest:^id {
			return [self describeKnowledgeSettings];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKKnowledgeSettings *)r);
		}];
}

/** Describe a list of FlexiPage and their contents */
-(void) performDescribeFlexiPages:(NSArray *)flexiPages contexts:(NSArray *)contexts
                        failBlock:(zkFailWithExceptionBlock)failBlock
                    completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self describeFlexiPages:flexiPages contexts:contexts];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Describe the items in an AppMenu */
-(void) performDescribeAppMenu:(NSString *)appMenuType networkId:(NSString *)networkId
                     failBlock:(zkFailWithExceptionBlock)failBlock
                 completeBlock:(zkCompleteDescribeAppMenuResultBlock)completeBlock {

	[self performRequest:^id {
			return [self describeAppMenu:appMenuType networkId:networkId];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKDescribeAppMenuResult *)r);
		}];
}

/** Describe Gloal and Themes */
-(void) performDescribeGlobalThemeWithFailBlock:(zkFailWithExceptionBlock)failBlock
                     completeBlock:(zkCompleteDescribeGlobalThemeBlock)completeBlock {

	[self performRequest:^id {
			return [self describeGlobalTheme];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKDescribeGlobalTheme *)r);
		}];
}

/** Describe Themes */
-(void) performDescribeTheme:(NSArray *)sobjectType
                   failBlock:(zkFailWithExceptionBlock)failBlock
               completeBlock:(zkCompleteDescribeThemeResultBlock)completeBlock {

	[self performRequest:^id {
			return [self describeTheme:sobjectType];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKDescribeThemeResult *)r);
		}];
}

/** Describe the layout of the given sObject or the given actionable global page. */
-(void) performDescribeLayout:(NSString *)sObjectType layoutName:(NSString *)layoutName recordTypeIds:(NSArray *)recordTypeIds
                    failBlock:(zkFailWithExceptionBlock)failBlock
                completeBlock:(zkCompleteDescribeLayoutResultBlock)completeBlock {

	[self performRequest:^id {
			return [self describeLayout:sObjectType layoutName:layoutName  recordTypeIds:recordTypeIds];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKDescribeLayoutResult *)r);
		}];
}

/** Describe the layout of the SoftPhone */
-(void) performDescribeSoftphoneLayoutWithFailBlock:(zkFailWithExceptionBlock)failBlock
                         completeBlock:(zkCompleteDescribeSoftphoneLayoutResultBlock)completeBlock {

	[self performRequest:^id {
			return [self describeSoftphoneLayout];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKDescribeSoftphoneLayoutResult *)r);
		}];
}

/** Describe the search view of an sObject */
-(void) performDescribeSearchLayouts:(NSArray *)sObjectType
                           failBlock:(zkFailWithExceptionBlock)failBlock
                       completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self describeSearchLayouts:sObjectType];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Describe a list of entity names that reflects the current user's searchable entities */
-(void) performDescribeSearchableEntities:(BOOL)includeOnlyEntitiesWithTabs
                                failBlock:(zkFailWithExceptionBlock)failBlock
                            completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self describeSearchableEntities:includeOnlyEntitiesWithTabs];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Describe a list of objects representing the order and scope of objects on a users search result page */
-(void) performDescribeSearchScopeOrderWithFailBlock:(zkFailWithExceptionBlock)failBlock
                          completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self describeSearchScopeOrder];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Describe the compact layouts of the given sObject */
-(void) performDescribeCompactLayouts:(NSString *)sObjectType recordTypeIds:(NSArray *)recordTypeIds
                            failBlock:(zkFailWithExceptionBlock)failBlock
                        completeBlock:(zkCompleteDescribeCompactLayoutsResultBlock)completeBlock {

	[self performRequest:^id {
			return [self describeCompactLayouts:sObjectType recordTypeIds:recordTypeIds];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKDescribeCompactLayoutsResult *)r);
		}];
}

/** Describe the Path Assistants for the given sObject and optionally RecordTypes */
-(void) performDescribePathAssistants:(NSString *)sObjectType picklistValue:(NSString *)picklistValue recordTypeIds:(NSArray *)recordTypeIds
                            failBlock:(zkFailWithExceptionBlock)failBlock
                        completeBlock:(zkCompleteDescribePathAssistantsResultBlock)completeBlock {

	[self performRequest:^id {
			return [self describePathAssistants:sObjectType picklistValue:picklistValue  recordTypeIds:recordTypeIds];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKDescribePathAssistantsResult *)r);
		}];
}

/** Describe the approval layouts of the given sObject */
-(void) performDescribeApprovalLayout:(NSString *)sObjectType approvalProcessNames:(NSArray *)approvalProcessNames
                            failBlock:(zkFailWithExceptionBlock)failBlock
                        completeBlock:(zkCompleteDescribeApprovalLayoutResultBlock)completeBlock {

	[self performRequest:^id {
			return [self describeApprovalLayout:sObjectType approvalProcessNames:approvalProcessNames];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKDescribeApprovalLayoutResult *)r);
		}];
}

/** Describe the ListViews as SOQL metadata for the generation of SOQL. */
-(void) performDescribeSoqlListViews:(ZKDescribeSoqlListViewsRequest *)request
                           failBlock:(zkFailWithExceptionBlock)failBlock
                       completeBlock:(zkCompleteDescribeSoqlListViewResultBlock)completeBlock {

	[self performRequest:^id {
			return [self describeSoqlListViews:request];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKDescribeSoqlListViewResult *)r);
		}];
}

/** Execute the specified list view and return the presentation-ready results. */
-(void) performExecuteListView:(ZKExecuteListViewRequest *)request
                     failBlock:(zkFailWithExceptionBlock)failBlock
                 completeBlock:(zkCompleteExecuteListViewResultBlock)completeBlock {

	[self performRequest:^id {
			return [self executeListView:request];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKExecuteListViewResult *)r);
		}];
}

/** Describe the ListViews of a SObject as SOQL metadata for the generation of SOQL. */
-(void) performDescribeSObjectListViews:(NSString *)sObjectType recentsOnly:(BOOL)recentsOnly isSoqlCompatible:(NSString *)isSoqlCompatible limit:(NSInteger)limit offset:(NSInteger)offset
                              failBlock:(zkFailWithExceptionBlock)failBlock
                          completeBlock:(zkCompleteDescribeSoqlListViewResultBlock)completeBlock {

	[self performRequest:^id {
			return [self describeSObjectListViews:sObjectType recentsOnly:recentsOnly  isSoqlCompatible:isSoqlCompatible  limit:limit  offset:offset];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKDescribeSoqlListViewResult *)r);
		}];
}

/** Describe the tabs that appear on a users page */
-(void) performDescribeTabsWithFailBlock:(zkFailWithExceptionBlock)failBlock
              completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self describeTabs];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Describe all tabs available to a user */
-(void) performDescribeAllTabsWithFailBlock:(zkFailWithExceptionBlock)failBlock
                 completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self describeAllTabs];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Describe the primary compact layouts for the sObjects requested */
-(void) performDescribePrimaryCompactLayouts:(NSArray *)sObjectTypes
                                   failBlock:(zkFailWithExceptionBlock)failBlock
                               completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self describePrimaryCompactLayouts:sObjectTypes];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Create a set of new sObjects */
-(void) performCreate:(NSArray *)sObjects
            failBlock:(zkFailWithExceptionBlock)failBlock
        completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self create:sObjects];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Update a set of sObjects */
-(void) performUpdate:(NSArray *)sObjects
            failBlock:(zkFailWithExceptionBlock)failBlock
        completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self update:sObjects];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Update or insert a set of sObjects based on object id */
-(void) performUpsert:(NSString *)externalIDFieldName sObjects:(NSArray *)sObjects
            failBlock:(zkFailWithExceptionBlock)failBlock
        completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self upsert:externalIDFieldName sObjects:sObjects];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Merge and update a set of sObjects based on object id */
-(void) performMerge:(NSArray *)request
           failBlock:(zkFailWithExceptionBlock)failBlock
       completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self merge:request];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Delete a set of sObjects */
-(void) performDelete:(NSArray *)ids
            failBlock:(zkFailWithExceptionBlock)failBlock
        completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self delete:ids];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Undelete a set of sObjects */
-(void) performUndelete:(NSArray *)ids
              failBlock:(zkFailWithExceptionBlock)failBlock
          completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self undelete:ids];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Empty a set of sObjects from the recycle bin */
-(void) performEmptyRecycleBin:(NSArray *)ids
                     failBlock:(zkFailWithExceptionBlock)failBlock
                 completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self emptyRecycleBin:ids];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Get a set of sObjects */
-(void) performRetrieve:(NSString *)fieldList sObjectType:(NSString *)sObjectType ids:(NSArray *)ids
              failBlock:(zkFailWithExceptionBlock)failBlock
          completeBlock:(zkCompleteDictionaryBlock)completeBlock {

	[self performRequest:^id {
			return [self retrieve:fieldList sObjectType:sObjectType  ids:ids];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSDictionary *)r);
		}];
}

/** Submit an entity to a workflow process or process a workitem */
-(void) performProcess:(NSArray *)actions
             failBlock:(zkFailWithExceptionBlock)failBlock
         completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self process:actions];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** convert a set of leads */
-(void) performConvertLead:(NSArray *)leadConverts
                 failBlock:(zkFailWithExceptionBlock)failBlock
             completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self convertLead:leadConverts];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Logout the current user, invalidating the current session. */
-(void) performLogoutWithFailBlock:(zkFailWithExceptionBlock)failBlock
        completeBlock:(zkCompleteVoidBlock)completeBlock {

	[self performRequest:^id {
			[self logout];
			return nil;
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock();
		}];
}

/** Logs out and invalidates session ids */
-(void) performInvalidateSessions:(NSArray *)sessionIds
                        failBlock:(zkFailWithExceptionBlock)failBlock
                    completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self invalidateSessions:sessionIds];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Get the IDs for deleted sObjects */
-(void) performGetDeleted:(NSString *)sObjectType startDate:(NSDate *)startDate endDate:(NSDate *)endDate
                failBlock:(zkFailWithExceptionBlock)failBlock
            completeBlock:(zkCompleteGetDeletedResultBlock)completeBlock {

	[self performRequest:^id {
			return [self getDeleted:sObjectType startDate:startDate  endDate:endDate];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKGetDeletedResult *)r);
		}];
}

/** Get the IDs for updated sObjects */
-(void) performGetUpdated:(NSString *)sObjectType startDate:(NSDate *)startDate endDate:(NSDate *)endDate
                failBlock:(zkFailWithExceptionBlock)failBlock
            completeBlock:(zkCompleteGetUpdatedResultBlock)completeBlock {

	[self performRequest:^id {
			return [self getUpdated:sObjectType startDate:startDate  endDate:endDate];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKGetUpdatedResult *)r);
		}];
}

/** Create a Query Cursor */
-(void) performQuery:(NSString *)queryString
           failBlock:(zkFailWithExceptionBlock)failBlock
       completeBlock:(zkCompleteQueryResultBlock)completeBlock {

	[self performRequest:^id {
			return [self query:queryString];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKQueryResult *)r);
		}];
}

/** Create a Query Cursor, including deleted sObjects */
-(void) performQueryAll:(NSString *)queryString
              failBlock:(zkFailWithExceptionBlock)failBlock
          completeBlock:(zkCompleteQueryResultBlock)completeBlock {

	[self performRequest:^id {
			return [self queryAll:queryString];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKQueryResult *)r);
		}];
}

/** Gets the next batch of sObjects from a query */
-(void) performQueryMore:(NSString *)queryLocator
               failBlock:(zkFailWithExceptionBlock)failBlock
           completeBlock:(zkCompleteQueryResultBlock)completeBlock {

	[self performRequest:^id {
			return [self queryMore:queryLocator];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKQueryResult *)r);
		}];
}

/** Search for sObjects */
-(void) performSearch:(NSString *)searchString
            failBlock:(zkFailWithExceptionBlock)failBlock
        completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self search:searchString];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Gets server timestamp */
-(void) performGetServerTimestampWithFailBlock:(zkFailWithExceptionBlock)failBlock
                    completeBlock:(zkCompleteGetServerTimestampResultBlock)completeBlock {

	[self performRequest:^id {
			return [self getServerTimestamp];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKGetServerTimestampResult *)r);
		}];
}

/** Set a user's password */
-(void) performSetPassword:(NSString *)userId password:(NSString *)password
                 failBlock:(zkFailWithExceptionBlock)failBlock
             completeBlock:(zkCompleteSetPasswordResultBlock)completeBlock {

	[self performRequest:^id {
			return [self setPassword:userId password:password];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKSetPasswordResult *)r);
		}];
}

/** Reset a user's password */
-(void) performResetPassword:(NSString *)userId
                   failBlock:(zkFailWithExceptionBlock)failBlock
               completeBlock:(zkCompleteResetPasswordResultBlock)completeBlock {

	[self performRequest:^id {
			return [self resetPassword:userId];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKResetPasswordResult *)r);
		}];
}

/** Returns standard information relevant to the current user */
-(void) performGetUserInfoWithFailBlock:(zkFailWithExceptionBlock)failBlock
             completeBlock:(zkCompleteUserInfoBlock)completeBlock {

	[self performRequest:^id {
			return [self getUserInfo];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKUserInfo *)r);
		}];
}

/** Send existing draft EmailMessage */
-(void) performSendEmailMessage:(NSArray *)ids
                      failBlock:(zkFailWithExceptionBlock)failBlock
                  completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self sendEmailMessage:ids];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Send outbound email */
-(void) performSendEmail:(NSArray *)messages
               failBlock:(zkFailWithExceptionBlock)failBlock
           completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self sendEmail:messages];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Perform a template merge on one or more blocks of text. */
-(void) performRenderEmailTemplate:(NSArray *)renderRequests
                         failBlock:(zkFailWithExceptionBlock)failBlock
                     completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self renderEmailTemplate:renderRequests];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Perform a series of predefined actions such as quick create or log a task */
-(void) performPerformQuickActions:(NSArray *)quickActions
                         failBlock:(zkFailWithExceptionBlock)failBlock
                     completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self performQuickActions:quickActions];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Describe the details of a series of quick actions */
-(void) performDescribeQuickActions:(NSArray *)quickActions
                          failBlock:(zkFailWithExceptionBlock)failBlock
                      completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self describeQuickActions:quickActions];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Describe the details of a series of quick actions available for the given contextType */
-(void) performDescribeAvailableQuickActions:(NSString *)contextType
                                   failBlock:(zkFailWithExceptionBlock)failBlock
                               completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self describeAvailableQuickActions:contextType];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Retreive the template sobjects, if appropriate, for the given quick action names in a given context */
-(void) performRetrieveQuickActionTemplates:(NSArray *)quickActionNames contextId:(NSString *)contextId
                                  failBlock:(zkFailWithExceptionBlock)failBlock
                              completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self retrieveQuickActionTemplates:quickActionNames contextId:contextId];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

/** Describe visualforce for an org */
-(void) performDescribeVisualForce:(BOOL)includeAllDetails namespacePrefix:(NSString *)namespacePrefix
                         failBlock:(zkFailWithExceptionBlock)failBlock
                     completeBlock:(zkCompleteDescribeVisualForceResultBlock)completeBlock {

	[self performRequest:^id {
			return [self describeVisualForce:includeAllDetails namespacePrefix:namespacePrefix];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((ZKDescribeVisualForceResult *)r);
		}];
}

/** Return the renameable nouns from the server for use in presentation using the salesforce grammar engine */
-(void) performDescribeNouns:(NSArray *)nouns onlyRenamed:(BOOL)onlyRenamed includeFields:(BOOL)includeFields
                   failBlock:(zkFailWithExceptionBlock)failBlock
               completeBlock:(zkCompleteArrayBlock)completeBlock {

	[self performRequest:^id {
			return [self describeNouns:nouns onlyRenamed:onlyRenamed  includeFields:includeFields];
		}
		 checkSession:YES
		    failBlock:failBlock
		completeBlock:^(id r) {
			if (completeBlock) completeBlock((NSArray *)r);
		}];
}

@end