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
    @date 1/12/2020
    @description This class is used to get the announcement message for single barrel portal.
*/
public class CNT_SBP_AnnouncementMessage {
    
    /**
    *  @description : This method is use to fetch the annoucement message.
    *  @return      : Map<String, Object>
    **/
    @AuraEnabled
    public static Map<String, Object> getAnnouncementMessage(String announcementType) {
        List<Announcement__c> lstAnnouncements = [SELECT Message__c FROM Announcement__c
            WHERE Type__c = :announcementType ORDER BY CreatedDate LIMIT 1];
        return lstAnnouncements.isEmpty() ? null : new Map<String, Object>{'message' => lstAnnouncements[0].Message__c};
    }

}