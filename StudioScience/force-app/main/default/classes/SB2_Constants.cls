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
    @date 11/05/2020
    @description This class is created to store constants related to Project Suspenders.
*/
public class SB2_Constants {
    public static final map<String, List<String>> mapOfQuarterMonth = new Map<String, List<String>>{
        'Quarter 1' => New List<String>{'January','February','March'},
            'Quarter 2' => New List<String>{'April','May','June'},
                'Quarter 3' => New List<String>{'July','August','September'},
                    'Quarter 4' => New List<String>{'October','November','December'}};
    public static final map<String, Integer> mapOfMonth = new Map<String, Integer>{'January' => 1,'February' => 2,'March' => 3,
        'April' => 4,'May' => 5,'June' => 6, 'July' => 7, 'August' => 8,'September' => 9 , 'October' => 10,
        'November' => 11,'December' => 12};
    public static final map<Integer, String> mapOfIntegerMonth = new Map<Integer, String>{1 => 'January', 2 => 'February', 3 => 'March',
        4 => 'April', 5 => 'May', 6 => 'June', 7 => 'July', 8 => 'August' , 9 =>'September', 10 =>'October',
        11 => 'November', 12 => 'December'};
    public static final map<Integer, String> mapOfIntegerQuarter = new Map<Integer, String>{1 => 'Quarter 1', 2 => 'Quarter 1',
        3 => 'Quarter 1', 4 => 'Quarter 2', 5 => 'Quarter 2', 6 => 'Quarter 2', 7 => 'Quarter 3', 8 => 'Quarter 3', 9 => 'Quarter 3',
        10 => 'Quarter 4', 11 => 'Quarter 4', 12 => 'Quarter 4'};
    public static final map<String, Integer> mapOfQuarter = new Map<String, Integer>{'Quarter 1' => 1, 'Quarter 2' => 4, 'Quarter 3' => 7,
        'Quarter 4' => 10};
	public static final String QUARTERLY = 'Quarterly';
    public static final String MONTHLY ='Monthly';
    public static final String YEARLY = 'Yearly';
    public static final String SEPERATOR = '~';
    public static final String JANUARY = 'January';
    public static final String CURRENT_YEAR = Date.today().year() + '';
    public static map<String, String> mapOfMonthQuarter = new Map<String, String>{'January' => 'Quarter 1', 'February' => 'Quarter 1', 'March' => 'Quarter 1',
                    'April' => 'Quarter 2', 'May' => 'Quarter 2', 'June' => 'Quarter 2', 'July' => 'Quarter 3', 'August' => 'Quarter 3', 'September' => 'Quarter 3',
                    'October' => 'Quarter 4', 'November' => 'Quarter 4', 'December' => 'Quarter 4'};
    
}