/**
    @company : Copyright © 2020, BeamSuntory
    All rights reserved.
    Redistribution and use in source form, with or without modification, are prohibited without the express written consent of BeamSuntory,Inc.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
    IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    @website : https://www.beamsuntory.com/
    @author BeamSuntory
    @version V_1.0
    @date 18/11/2020
    @description This test class is created to test SLT_User.
*/
@IsTest(seeAllData = false)
public class TST_SLT_User {
    /**
    *  @description : This method is use to test if List of user is returned through Id
    **/
    @IsTest
    public static void testGetUserDetail() {
        String userId = [SELECT Id FROM User where name = 'SFDC Integration' LIMIT 1].Id;
        
        Test.startTest();
        	List<User> result= SLT_User.getUserDetail(userId);
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'User is fetched is fetched');
    }
    
    //Added by Nishant khandal
    @IsTest
    public static void testGetUserDetailUsername() {
        String userName = [SELECT Id, UserName FROM User 
                              WHERE Name = 'SFDC Integration' 
                              LIMIT 1].UserName;
        
        Test.startTest();
        List<User> result= SLT_User.getUserDetailUsername(userName);
        Test.stopTest();
        System.assertEquals(false, result.isEmpty(), 'User is fetched');
    }
}