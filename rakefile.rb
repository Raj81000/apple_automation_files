# Rakefile

require 'tempfile'

desc "Move emails based on complex criteria from a local JSON file"
task :move_emails, [:file_name] do |t, args|
  require 'json'
  
  file_path = File.join(File.dirname(__FILE__), args[:file_name])
  
  # Load criteria from the local JSON file
  criteria_hash = JSON.parse(File.read(file_path))

  subject = criteria_hash["subject"] || ""
  account_name = criteria_hash["account_name"] || "iCloud"
  mailbox = criteria_hash["mailbox"] || "INBOX"
  target_folder = criteria_hash["target_folder"] || "Archive"
  
  apple_script_content = <<-APPLESCRIPT
    tell application "Mail"
      set targetAccount to account "#{account_name}"
      set sourceMailbox to mailbox "#{mailbox}" of targetAccount
      set targetMailbox to mailbox "#{target_folder}" of targetAccount
      set theMessages to every message of sourceMailbox whose subject contains "#{subject}"
      repeat with msg in theMessages
        move msg to targetMailbox
      end repeat
    end tell
  APPLESCRIPT
  
  # Create a temporary file
  Tempfile.open('move_emails_script') do |f|
    f.write(apple_script_content)
    f.close
    # Execute the AppleScript from the temporary file
    system "osascript #{f.path}"
  end
  
  puts "Moved emails with criteria to '#{target_folder}' in '#{mailbox}' of account '#{account_name}'."
end


desc "Move Apple emails"
task :move_apple_emails do |t|
  
  apple_script_content = <<-APPLESCRIPT
    tell application "Mail"
    -- Define the target mailbox where emails will be moved
    set targetMailbox to mailbox "Apple Receipts" of account "iCloud"
    
    -- List of mailboxes to search through, starting with the Inbox
    set mailboxesToSearch to {mailbox "INBOX" of account "iCloud"}
    
    -- Add any mailbox that includes "Apple" in its name to the search list
    repeat with aMailbox in every mailbox of account "iCloud"
        if name of aMailbox contains "Apple" then
            set end of mailboxesToSearch to aMailbox
        end if
    end repeat
    
    -- Loop through each mailbox to search for emails meeting the criteria
    repeat with currentMailbox in mailboxesToSearch
        set theMessages to every message of currentMailbox whose subject contains "invoice" and sender contains "apple"
        -- Move each found message to the target mailbox
        repeat with thisMessage in theMessages
            move thisMessage to targetMailbox
        end repeat
    end repeat
  end tell
  APPLESCRIPT
  
  # Create a temporary file
  Tempfile.open('move_apple_emails') do |f|
    f.write(apple_script_content)
    f.close
    # Execute the AppleScript from the temporary file
    system "osascript #{f.path}"
  end
  
  puts "Moved specified Apple Emails."
end

desc "Move Apple emails based on subject"
task :move_apple_by_subject_emails do |t|
  
  apple_script_content = <<-APPLESCRIPT
    tell application "Mail"
        set myAccount to account "iCloud"
        
        -- Define target mailboxes for different subjects
        set receiptsMailbox to mailbox "Apple Receipts" of myAccount
        set subscriptionsMailbox to mailbox "Apple Subscription" of myAccount
        set ordersMailbox to mailbox "Apple Orders" of myAccount
        set appleSupportMailbox to mailbox "Apple Support" of myAccount
        
        -- List of mailboxes to search through, starting with the Inbox
        set mailboxesToSearch to {mailbox "INBOX" of myAccount}
        
        -- Loop through each mailbox to search for emails meeting the criteria
        repeat with currentMailbox in mailboxesToSearch
            set theMessages to every message of currentMailbox whose sender contains "apple"
            
            repeat with thisMessage in theMessages
                if sender of thisMessage contains "Apple Support" or subject of thisMessage contains "Support" then
                  -- Move to Apple Support
                  move thisMessage to appleSupportMailbox
                else if subject of thisMessage contains "Invoice" or subject of thisMessage contains "Receipt" then
                    -- Move to Apple Receipts
                    move thisMessage to receiptsMailbox
                else if subject of thisMessage contains "Subscription" then
                    -- Move to Apple Subscriptions
                    move thisMessage to subscriptionsMailbox
                else if subject of thisMessage contains "Order" or subject of thisMessage contains "Dispatch Notification" or subject of thisMessage contains "Return Number" or subject of thisMessage contains "refund" then
                    -- Move to Apple Orders
                    move thisMessage to ordersMailbox
                end if
            end repeat
        end repeat
    end tell
  APPLESCRIPT
  
  # Create a temporary file
  Tempfile.open('move_apple_by_subject_emails') do |f|
    f.write(apple_script_content)
    f.close
    # Execute the AppleScript from the temporary file
    system "osascript #{f.path}"
  end
  
  puts "Moved specified Apple Emails based on subject."
end



desc "Move marketing emails to junk"
task :junk_inbox_and_subfolder_marketing_emails do |t|
  
  apple_script_content = <<-APPLESCRIPT
    tell application "Mail"
        set myAccount to "iCloud" -- Adjust as necessary
        set junkMailbox to mailbox "Junk" of account myAccount
        set conditions to {¬
          {subjectContains:"Get ", senderContains:"AXS"}, ¬
          {subjectContains:"early access", senderContains:"AXS"}, ¬
          {subjectContains:"on Sale", senderContains:"AXS"}, ¬
          {subjectContains:"AXS!", senderContains:"AXS"}, ¬
          {subjectContains:"Welcome", senderContains:"audi"}, ¬
          {subjectContains:"", senderContains:"via LinkedIn"}, ¬
          {subjectContains:"", senderContains:"notifications-noreply@linkedin.com"}, ¬
          {subjectContains:"", senderContains:"jobalerts-noreply@linkedin.com"}, ¬
          {subjectContains:"", senderContains:"linkedin@e.linkedin.com"}, ¬
          {subjectContains:"I want to connect", senderContains:"linkedin"}, ¬
          {subjectContains:"", senderContains:"invitations@linkedin.com"}, ¬
          {subjectContains:"", senderContains:"messaging-digest-noreply@linkedin.com"}, ¬
          {subjectContains:"Raj", senderContains:"bupa"}, ¬
          {subjectContains:"", senderContains:"sme@comm.bupa.com"}, ¬
          {subjectContains:"", senderContains:"no-reply@accounts.google.com"}, ¬
          {subjectContains:"", senderContains:"noreply@communications.coutts.com"}, ¬
          {subjectContains:"", senderContains:"shopnews@hodinkee.com"}, ¬
          {subjectContains:"", senderContains:"replies@m.lastpass.com"}, ¬
          {subjectContains:"", senderContains:"Asset Management"}, ¬
          {subjectContains:"", senderContains:"Private Clients"}, ¬
          {subjectContains:"", senderContains:"Client Management"}, ¬
          {subjectContains:"", senderContains:"Peter Flavel"}, ¬
          {subjectContains:"", senderContains:"James Clarry"}, ¬
          {subjectContains:"New Document", senderContains:"coutts"}, ¬
          {subjectContains:"", senderContains:"no-reply@dashlane.com"}, ¬
          {subjectContains:"order confirmation", senderContains:"porter"}, ¬
          {subjectContains:"", senderContains:"emails@email.net-a-porter.com"}, ¬
          {subjectContains:"collection", senderContains:"premier"}, ¬
          {subjectContains:"- order", senderContains:"customercare"}, ¬
          {subjectContains:"", senderContains:"no-reply@getfareye.com"}, ¬
          {subjectContains:"", senderContains:"Personal Shopping"}, ¬
          {subjectContains:"order", senderContains:"NoReply@notifications.mrporter.com"}, ¬
          {subjectContains:"order", senderContains:"returns@net-a-porter.com"}, ¬
          {subjectContains:"New Arrivals", senderContains:""}, ¬
          {subjectContains:"EIP Preview", senderContains:""}, ¬
          {subjectContains:"", senderContains:"news@email.mrporter.com"}, ¬
          {subjectContains:"", senderContains:"customercare@emails.mrporter.com"}, ¬
          {subjectContains:"", senderContains:"news@email.mrporter.com"}, ¬
          {subjectContains:"", senderContains:"NoReply.ODD@dhl.com"}, ¬
          {subjectContains:"Security Notification", senderContains:"support@namecheap.com"}, ¬
          {subjectContains:"", senderContains:"smugmugteam@flash.smugmug.com"}, ¬
          {subjectContains:"", senderContains:"HLAlumni@e.hoganlovells.com"}, ¬
          {subjectContains:"refund", senderContains:"porter"} ¬
        }
        
        -- Iterate through each top-level mailbox in the account
        repeat with aTopLevelMailbox in every mailbox of account myAccount
            -- Apply conditions to each message within the mailbox
            repeat with thisCondition in conditions
                set subjectCondition to subjectContains of thisCondition
                set senderCondition to senderContains of thisCondition
                
                -- Determine the set of messages to process based on conditions
                if subjectCondition is not equal to "" and senderCondition is not equal to "" then
                    set theMessages to every message of aTopLevelMailbox whose subject contains subjectCondition and sender contains senderCondition
                else if subjectCondition is not equal to "" then
                    set theMessages to every message of aTopLevelMailbox whose subject contains subjectCondition
                else if senderCondition is not equal to "" then
                    set theMessages to every message of aTopLevelMailbox whose sender contains senderCondition
                end if
                
                -- Move matching messages to the Junk mailbox
                repeat with thisMessage in theMessages
                    move thisMessage to junkMailbox
                end repeat
            end repeat
        end repeat
    end tell
    APPLESCRIPT


  
  # Create a temporary file
  Tempfile.open('junk_inbox_and_subfolder_marketing_emails') do |f|
    f.write(apple_script_content)
    f.close
    # Execute the AppleScript from the temporary file
    system "osascript #{f.path}"
  end
  
  puts "Junked Marketing Emails."
end


desc "Move marketing emails to junk"
task :junk_marketing_emails do |t|
  
  apple_script_content = <<-APPLESCRIPT
tell application "Mail"
    set myAccount to "iCloud" -- Adjust as necessary
    set myInbox to mailbox "INBOX" of account myAccount
    set junkMailbox to mailbox "Junk" of account myAccount
    set conditions to {¬
      {subjectContains:"Get ", senderContains:"AXS"}, ¬
      {subjectContains:"early access", senderContains:"AXS"}, ¬
      {subjectContains:"on Sale", senderContains:"AXS"}, ¬
      {subjectContains:"AXS!", senderContains:"AXS"}, ¬
      {subjectContains:"Welcome", senderContains:"audi"}, ¬
      {subjectContains:"", senderContains:"via LinkedIn"}, ¬
      {subjectContains:"", senderContains:"notifications-noreply@linkedin.com"}, ¬
      {subjectContains:"", senderContains:"jobalerts-noreply@linkedin.com"}, ¬
      {subjectContains:"", senderContains:"linkedin@e.linkedin.com"}, ¬
      {subjectContains:"I want to connect", senderContains:"linkedin"}, ¬
      {subjectContains:"", senderContains:"invitations@linkedin.com"}, ¬
      {subjectContains:"", senderContains:"messaging-digest-noreply@linkedin.com"}, ¬
      {subjectContains:"Raj", senderContains:"bupa"}, ¬
      {subjectContains:"", senderContains:"sme@comm.bupa.com"}, ¬
      {subjectContains:"", senderContains:"no-reply@accounts.google.com"}, ¬
      {subjectContains:"", senderContains:"noreply@communications.coutts.com"}, ¬
      {subjectContains:"", senderContains:"shopnews@hodinkee.com"}, ¬
      {subjectContains:"", senderContains:"replies@m.lastpass.com"}, ¬
      {subjectContains:"", senderContains:"Asset Management"}, ¬
      {subjectContains:"", senderContains:"Private Clients"}, ¬
      {subjectContains:"", senderContains:"Client Management"}, ¬
      {subjectContains:"", senderContains:"Peter Flavel"}, ¬
      {subjectContains:"", senderContains:"James Clarry"}, ¬
      {subjectContains:"New Document", senderContains:"coutts"}, ¬
      {subjectContains:"", senderContains:"no-reply@dashlane.com"}, ¬
      {subjectContains:"order confirmation", senderContains:"porter"}, ¬
      {subjectContains:"", senderContains:"emails@email.net-a-porter.com"}, ¬
      {subjectContains:"collection", senderContains:"premier"}, ¬
      {subjectContains:"- order", senderContains:"customercare"}, ¬
      {subjectContains:"", senderContains:"no-reply@getfareye.com"}, ¬
      {subjectContains:"", senderContains:"Personal Shopping"}, ¬
      {subjectContains:"order", senderContains:"NoReply@notifications.mrporter.com"}, ¬
      {subjectContains:"order", senderContains:"returns@net-a-porter.com"}, ¬
      {subjectContains:"New Arrivals", senderContains:""}, ¬
      {subjectContains:"EIP Preview", senderContains:""}, ¬
      {subjectContains:"", senderContains:"news@email.mrporter.com"}, ¬
      {subjectContains:"", senderContains:"customercare@emails.mrporter.com"}, ¬
      {subjectContains:"", senderContains:"news@email.mrporter.com"}, ¬
      {subjectContains:"", senderContains:"NoReply.ODD@dhl.com"}, ¬
      {subjectContains:"Security Notification", senderContains:"support@namecheap.com"}, ¬
      {subjectContains:"", senderContains:"smugmugteam@flash.smugmug.com"}, ¬
      {subjectContains:"", senderContains:"HLAlumni@e.hoganlovells.com"}, ¬
      {subjectContains:"refund", senderContains:"porter"} ¬
    }
    
    -- Apply conditions to each message within the Inbox
    repeat with thisCondition in conditions
        set subjectCondition to subjectContains of thisCondition
        set senderCondition to senderContains of thisCondition
        
        -- Determine the set of messages to process based on conditions
        if subjectCondition is not equal to "" and senderCondition is not equal to "" then
            set theMessages to every message of myInbox whose subject contains subjectCondition and sender contains senderCondition
        else if subjectCondition is not equal to "" then
            set theMessages to every message of myInbox whose subject contains subjectCondition
        else if senderCondition is not equal to "" then
            set theMessages to every message of myInbox whose sender contains senderCondition
        end if
        
        -- Move matching messages to the Junk mailbox
        repeat with thisMessage in theMessages
            move thisMessage to junkMailbox
        end repeat
    end repeat
end tell
APPLESCRIPT

# Create a temporary file
Tempfile.open('junk_marketing_emails') do |f|
    f.write(apple_script_content)
    f.close
    # Execute the AppleScript from the temporary file
    system "osascript #{f.path}"
end

puts "Junked Marketing Emails."

end


desc "File rbodderick emails"
task :file_emails do |t|
  
  apple_script_content = <<-APPLESCRIPT
    tell application "Mail"
    set myAccount to account "RBodderick Gmail" -- Replace with your account name
    set theInbox to mailbox "INBOX" of myAccount
    set theMessages to every message of theInbox
    
    -- Define your array of records with sender and target folder names
    set emailConditions to {¬
        {sender:"no-reply@nexudus.com", folderName:"Colony"}, ¬
        {sender:"lfc@emails.liverpoolfc.com", folderName:"LiverpoolFC"}¬
        }
    
    -- Iterate through each condition
    repeat with aCondition in emailConditions
        set targetSender to sender of aCondition
        set targetFolderName to folderName of aCondition
        
        -- Check if target folder exists, if not, create it
        try
            set targetFolder to mailbox targetFolderName of myAccount
        on error
            set targetFolder to make new mailbox with properties {name:targetFolderName} at myAccount
        end try
        
        -- Iterate through messages in the Inbox
        repeat with aMessage in theMessages
            if sender of aMessage contains targetSender then
                -- Move the message to the target folder
                move aMessage to targetFolder
            end if
        end repeat
      end repeat
    end tell
  APPLESCRIPT
  
  # Create a temporary file
  Tempfile.open('file_emails') do |f|
      f.write(apple_script_content)
      f.close
      # Execute the AppleScript from the temporary file
      system "osascript #{f.path}"
  end

  puts "Filed RBodderick Emails."

end

desc "File LawFairy emails based on conditions"
task :file_lawfairy_emails do |t|

  apple_script_content = <<-APPLESCRIPT
  tell application "Mail"
  -- Define accounts and conditions
  set accountNames to {"LawFairy"} -- Adjust with your account names
  set emailConditions to {¬
    {sender:"incidentalerts", subject:"", folderName:"Security"}, ¬
    {sender:"no_reply@euc1.monday.com", subject:"", folderName:"Junk"}, ¬
    {sender:"hnueaofinbark@gmail.com", subject:"", folderName:"Junk"}, ¬
    {sender:"theteam@email.legalex.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"info@legaltech-talk.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@peimedia.com", subject:"", folderName:"Junk"}, ¬
    {sender:".intercom-mail.com", subject:"", folderName:"Junk"}, ¬
    {sender:"no-reply@lawsociety.org.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"marketing@postman.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@explainerfly.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@mgamt.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@clwawards.com", subject:"", folderName:"Junk"}, ¬
    {sender:"contact@nfj.org.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"@bairesdev.com", subject:"", folderName:"Junk"}, ¬
    {sender:"justpark.com", subject:"", folderName:"Junk"}, ¬
    {sender:"privateequityinternational.com", subject:"", folderName:"Junk"}, ¬
    {sender:"professionalupdate@lawsociety.org.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"@chimoney.io", subject:"", folderName:"Junk"}, ¬
    {sender:"team@use.mail.monday.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@feedbirdnet.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@trustpilotmail.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@betterproducts.pro", subject:"", folderName:"Junk"}, ¬
    {sender:"@imageninsights", subject:"", folderName:"Junk"}, ¬
    {sender:"@ideas-forums.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@ideasforums", subject:"", folderName:"Junk"}, ¬
    {sender:"@recbid.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@opusrs.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@legallearningstudio.com", subject:"", folderName:"Junk"}, ¬
    {sender:"hypeteq", subject:"", folderName:"Junk"}, ¬
    {sender:"lawyersofdistinction", subject:"", folderName:"Junk"}, ¬
    {sender:"@ganttify.com", subject:"", folderName:"Junk"}, ¬
    {sender:"info@placedobson.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"info@placedobson.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"kajabimail.com", subject:"", folderName:"Junk"}, ¬
    {sender:"funnel-boost", subject:"", folderName:"Junk"}, ¬
    {sender:"", subject:"Attendees Data-List", folderName:"Junk"}, ¬
    {sender:"", subject:"Attendees Data List", folderName:"Junk"}, ¬
    {sender:"@benefit-focus.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@researchgatemail.net", subject:"", folderName:"Junk"}, ¬
    {sender:"support-feedback@stripe.com", subject:"", folderName:"Junk"}, ¬
    {sender:"CustomerExperience", subject:"", folderName:"Junk"}, ¬
    {sender:"@hampshireleadgeneration.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"hello@universe.com", subject:"", folderName:"Junk"}, ¬
    {sender:"crow-global.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@thesjp.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"dse_demo@docusign.net", subject:"", folderName:"Junk"}, ¬
    {sender:"@gerrish-legal.com", subject:"", folderName:"Junk"}, ¬
    {sender:"", subject:"Website Marketing Services", folderName:"Junk"}, ¬
    {sender:"@zendesk.com", subject:"", folderName:"Junk"}, ¬
    {sender:"techlist@gmail.com", subject:"", folderName:"Junk"}, ¬
    {sender:"certifiedsafepages", subject:"", folderName:"Junk"}, ¬
    {sender:"info@e.atlassian.com", subject:"", folderName:"Junk"}, ¬
    {sender:"no-reply@dashlane.com", subject:"", folderName:"Junk"}, ¬
    {sender:"athyna.com", subject:"", folderName:"Junk"}, ¬
    {sender:"connectos", subject:"", folderName:"Junk"}, ¬
    {sender:"htmlmonks", subject:"", folderName:"Junk"}, ¬
    {sender:"updates@goodlawproject.org", subject:"", folderName:"Junk"}, ¬
    {sender:"events@invite.economist.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@pioneerlogics", subject:"", folderName:"Junk"}, ¬
    {sender:"@lemonlightproductions.net", subject:"", folderName:"Junk"}, ¬
    {sender:"@joinkula.io", subject:"", folderName:"Junk"}, ¬
    {sender:"@grantedonline.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"productmarketing@lawsociety.org.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"@ringplan.co", subject:"", folderName:"Junk"}, ¬
    {sender:"@palqee.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@info", subject:"", folderName:"Junk"}, ¬
    {sender:"@tekalley", subject:"", folderName:"Junk"}, ¬
    {sender:"@pro-se.pro", subject:"", folderName:"Junk"}, ¬
    {sender:"@elevandi.io", subject:"", folderName:"Junk"}, ¬
    {sender:"tinkerdev", subject:"", folderName:"Junk"}, ¬
    {sender:"coda.io", subject:"", folderName:"Junk"}, ¬
    {sender:"Kandji Blog", subject:"", folderName:"Junk"}, ¬
    {sender:"membercomms@lawsociety.org.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"@enticeable.co", subject:"", folderName:"Junk"}, ¬
    {sender:"@beingguided.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@ad-ition.co", subject:"", folderName:"Junk"}, ¬
    {sender:"@pc-macsupport.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"Steve.King@lawsociety.org.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"@inktraptech.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@wearesopro.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"@pulsetic.co", subject:"", folderName:"Junk"}, ¬
    {sender:"@inspiration-space-mail.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"@email", subject:"", folderName:"Junk"}, ¬
    {sender:"@taylorhawkes.com", subject:"", folderName:"Junk"}, ¬
    {sender:"jobsity", subject:"", folderName:"Junk"}, ¬
    {sender:"@gmail", subject:"media enquiry", folderName:"Junk"}, ¬
    {sender:"@gmail", subject:"media question", folderName:"Junk"}, ¬
    {sender:"@levitydigital.com", subject:"media question", folderName:"Junk"}, ¬
    {sender:"Kandji Team", subject:"", folderName:"Junk"}, ¬
    {sender:"", subject:"Website Development", folderName:"Junk"}, ¬
    {sender:"support@npmjs.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@getlegal.com", subject:"", folderName:"Junk"}, ¬
    {sender:"secondariesinvestor.com", subject:"", folderName:"Junk"}, ¬
    {sender:"outlook.com", subject:"Website Design", folderName:"Junk"}, ¬
    {sender:"gmail.com", subject:"Website Design", folderName:"Junk"}, ¬
    {sender:"hotmail.com", subject:"Website Design", folderName:"Junk"}, ¬
    {sender:"@mail.", subject:"", folderName:"Junk"}, ¬
    {sender:"dbdiagram@holistics.io", subject:"", folderName:"Junk"}, ¬
    {sender:"no-reply@fintechfest.sg", subject:"", folderName:"Junk"}, ¬
    {sender:"@grantedonline.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"info@lexisnexis.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"hello@updates.starlingbank.com", subject:"", folderName:"Junk"}, ¬
    {sender:"", subject:"News report queries to Raj Panasar", folderName:"Junk"}, ¬
    {sender:"", subject:"News report queries to LawFairy", folderName:"Junk"}, ¬
    {sender:"@outbound.studio", subject:"", folderName:"Junk"}, ¬
    {sender:"thehubspotteam@hubspot.com", subject:"", folderName:"Junk"}, ¬
    {sender:"training@e.infosecinstitute.com", subject:"", folderName:"Junk"}, ¬
    {sender:"GazetteJobs@lawsociety.org.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"info@grandbeachhotel.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@sgfintechfest.co", subject:"", folderName:"Junk"}, ¬
    {sender:"no-reply@docker.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@theinterngroup.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@yololiv.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@zoommail", subject:"", folderName:"Junk"}, ¬
    {sender:"do-not-reply@economist.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@paristep.com", subject:"", folderName:"Junk"}, ¬
    {sender:"joinkula", subject:"", folderName:"Junk"}, ¬
    {sender:"@epicoservices.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@alternativeevents.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"@westminsterbusinessforum.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"@westminster", subject:"", folderName:"Junk"}, ¬
    {sender:"@westminsterlegalpolicyforum.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"@westminstereforum.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"@westminsteremploymentforum.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"organic.ly", subject:"", folderName:"Junk"}, ¬
    {sender:"@outbase-b2b.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@marketsgroup.org", subject:"", folderName:"Junk"}, ¬
    {sender:"emma.waite@e.infosecinstitute.com", subject:"", folderName:"Junk"}, ¬
    {sender:"venturecapitaljournal.com", subject:"", folderName:"Junk"}, ¬
    {sender:"", subject:"List of Media Industry", folderName:"Junk"}, ¬
    {sender:"", subject:"Mailing List", folderName:"Junk"}, ¬
    {sender:"@leadsruptive.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@meetsdrlabs.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@fmsend.net", subject:"", folderName:"Junk"}, ¬
    {sender:"@inpdtraining.co.uk", subject:"", folderName:"Junk"}, ¬
    {sender:"events@activecampaign.com", subject:"", folderName:"Junk"}, ¬
    {sender:"mikevasilev@outlook.com", subject:"", folderName:"Junk"}, ¬
    {sender:"roguelogics", subject:"", folderName:"Junk"}, ¬
    {sender:"@sme-mail.com", subject:"", folderName:"Junk"}, ¬
    {sender:"innovateuk@info.innovateuk.org", subject:"New funding", folderName:"Junk"}, ¬
    {sender:"updates@goodlawproject.org", subject:"", folderName:"Junk"}, ¬
    {sender:"scottleaa0@gmail.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@lucidchart.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@confirmed360.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@ntaskmanager.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@e.hoganlovells.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@purelogicsdevs", subject:"", folderName:"Junk"}, ¬
    {sender:"@mavenup", subject:"", folderName:"Junk"}, ¬
    {sender:"@ehoganlovells.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@trycasetext.com", subject:"", folderName:"Junk"}, ¬
    {sender:"@sharkzmarketing.com", subject:"", folderName:"Junk"}, ¬
    {sender:"julian@clwawards.com", subject:"", folderName:"Junk"}, ¬
    {sender:"notifications@securityiqeu-notifications.com", subject:"", folderName:"Cengage Notifications"}, ¬
    {sender:"securityiqeu", subject:"", folderName:"Cengage Notifications"}, ¬
    {sender:"@wfw.com", subject:"", folderName:"WFW"}, ¬
    {sender:"noreply@order.eventbrite.com", subject:"", folderName:"Eventbrite"}, ¬
    {sender:"@thelawyer.com", subject:"", folderName:"Lawyer"}, ¬
    {sender:"@uk.bnpparibas.com", subject:"", folderName:"BNPP"}, ¬
    {sender:"@slack.com", subject:"", folderName:"Slack"}, ¬
    {sender:"slackhq.com", subject:"", folderName:"Slack"}, ¬
    {sender:"@duellix.com", subject:"", folderName:"Duellix"}, ¬
    {sender:"@riipennetwork.com", subject:"", folderName:"Potential Supplier"}, ¬
    {sender:"william@nextbigthingconsulting.com", subject:"", folderName:"Potential Supplier"}, ¬
    {sender:"@jamf.com", subject:"", folderName:"Jamf"}, ¬
    {sender:"Jamf", subject:"", folderName:"Jamf"}, ¬
    {sender:"antony.a@hotmail.com", subject:"", folderName:"Film Sponsorship"}, ¬
    {sender:"bernard@kordieh.com", subject:"", folderName:"Film Sponsorship"}, ¬
    {sender:"@hootsuite.com", subject:"", folderName:"Hootsuite"}, ¬
    {sender:"nycourts.gov", subject:"", folderName:"NY Bar"}, ¬
    {sender:"@ipgroupplc.com", subject:"", folderName:"IP Group"}, ¬
    {sender:"@alexandralunn.com", subject:"", folderName:"Miscellaneous"}, ¬
    {sender:"@quotientapp.com", subject:"", folderName:"Miscellaneous"}, ¬
    {sender:"@azoprint.com", subject:"", folderName:"Miscellaneous"}, ¬
    {sender:"samuelkasumu", subject:"", folderName:"Miscellaneous"}, ¬
    {sender:"@theconduit.com", subject:"", folderName:"Conduit"}, ¬
    {sender:"@caitlinmcfee.com", subject:"", folderName:"Caitlin"}, ¬
    {sender:"@topos.institute", subject:"", folderName:"Topos"}, ¬
    {sender:"@fcdo.gov.uk", subject:"", folderName:"Government"}, ¬
    {sender:"@red-gate.com", subject:"", folderName:"Red-Gate"}, ¬
    {sender:"@davispolk.com", subject:"", folderName:"Davis Polk"}, ¬
    {sender:"@SlaughterandMay.com", subject:"", folderName:"Slaughter & May"}, ¬
    {sender:"@bloomberg.net", subject:"", folderName:"Bloomberg"}, ¬
    {sender:"", subject:"Wavelength", folderName:"Wavelength"}, ¬
    {sender:"@circular11.com", subject:"", folderName:"Circular11"}, ¬
    {sender:"@associo.com", subject:"", folderName:"Associo"}, ¬
    {sender:"@aimpathy.ai", subject:"", folderName:"Andrew Wood"}, ¬
    {sender:"@rationalip.com", subject:"", folderName:"IP"}, ¬
    {sender:"tlblaw", subject:"", folderName:"TLB"}, ¬
    {sender:"@tlb.law", subject:"", folderName:"TLB"}, ¬
    {sender:"vincent.slingerland@lexisnexis.com", subject:"", folderName:"Vincent Slingerland"}, ¬
    {sender:"gs.com", subject:"", folderName:"Goldman Sachs"}, ¬
    {sender:"Anna Meek", subject:"", folderName:"Goldman Sachs"}, ¬
    {sender:"@capacityapp.io", subject:"", folderName:"Capacity App"}, ¬
    {sender:"julian.richard@extense.co.uk", subject:"", folderName:"Julian Richard"}, ¬
    {sender:"sra.org.uk", subject:"", folderName:"SRA"}, ¬
    {sender:"Solicitors Regulatory", subject:"", folderName:"SRA"}, ¬
    {sender:"", subject:"Solicitors Regulation Authority", folderName:"SRA"}, ¬
    {sender:"Bintay.Shah@PACONSULTING.COM", subject:"", folderName:"SRA"}, ¬
    {sender:"noresponse@innovateuk.gov.uk", subject:"", folderName:"Innovate UK"}, ¬
    {sender:"@gdf.io", subject:"", folderName:"Crypto"}, ¬
    {sender:"peter.tracey@blackdown.com", subject:"", folderName:"Blackdown"}, ¬
    {sender:"openai.com", subject:"", folderName:"OpenAI"}, ¬
    {sender:"@imperial.ac.uk", subject:"", folderName:"Imperial"}, ¬
    {sender:"DCoppel@mofo.com", subject:"", folderName:"Daniel Coppel"}, ¬
    {sender:"daniel.coppel", subject:"", folderName:"Daniel Coppel"}, ¬
    {sender:"@faegredrinker", subject:"", folderName:"Daniel Coppel"}, ¬
    {sender:"trishawing@outlook.com", subject:"", folderName:"Trisha Wing"}, ¬
    {sender:"@sulehub.com", subject:"", folderName:"Trisha Wing"}, ¬
    {sender:"scott@hotbutter.design", subject:"", folderName:"UX"}, ¬
    {sender:"scott@scottherrington.com", subject:"", folderName:"UX"}, ¬
    {sender:"@stonebridgecorporate.com", subject:"", folderName:"Stonebridge"}, ¬
    {sender:"@democracyclub.org.uk", subject:"", folderName:"Democracy Club"}, ¬
    {sender:"emma@goodlawproject.org", subject:"", folderName:"GoodLawProject"}, ¬
    {sender:"sarah@goodlawproject.org", subject:"", folderName:"GoodLawProject"}, ¬
    {sender:"@portswigger.net", subject:"", folderName:"Burp"}, ¬
    {sender:"@sidley.com", subject:"", folderName:"Sidley"}, ¬
    {sender:"@cityfalcon.com", subject:"", folderName:"CityFalcon"}, ¬
    {sender:"charlotte.valeur@global-governance-group.com", subject:"", folderName:"Charlotte Valeur"}, ¬
    {sender:"Gonzalo Diaz", subject:"", folderName:"Gonzalo Diaz"}, ¬
    {sender:"@kineofinance.com", subject:"", folderName:"Olivier"}, ¬
    {sender:"StraussM@ebrd.com", subject:"", folderName:"Mike Strauss"}, ¬
    {sender:"@reorg.com", subject:"", folderName:"Reorg"}, ¬
    {sender:"@reorg-research.com", subject:"", folderName:"Reorg"}, ¬
    {sender:"@fuelandmove.com", subject:"", folderName:"Parul"}, ¬
    {sender:"parulcbpatel@gmail.com", subject:"", folderName:"Parul"}, ¬
    {sender:"starlingbank.com", subject:"", folderName:"Starling"}, ¬
    {sender:"Hayley.Waskett@fcdo.gov.uk", subject:"", folderName:"Government"}, ¬
    {sender:"@blackrock.com", subject:"", folderName:"Blackrock"}, ¬
    {sender:"@canva.com", subject:"", folderName:"Canva"}, ¬
    {sender:"cc@exadin.com", subject:"", folderName:"Charlotte Crosswell"}, ¬
    {sender:"Mark.Austin@freshfields.com", subject:"", folderName:"Mark Austin"}, ¬
    {sender:"Mark.Austin@lw.com", subject:"", folderName:"Mark Austin"}, ¬
    {sender:"mark.austin@lw.com", subject:"", folderName:"Mark Austin"}, ¬
    {sender:"@zlx.co.uk", subject:"", folderName:"RRD"}, ¬
    {sender:"@fi-group.com", subject:"", folderName:"RRD"}, ¬
    {sender:"@RIFTGroup.com", subject:"", folderName:"RRD"}, ¬
    {sender:"justgiving.com", subject:"", folderName:"Justgiving"}, ¬
    {sender:"@british-assessment.co.uk", subject:"", folderName:"ISO"}, ¬
    {sender:"guybennettjones@hotmail.co.uk", subject:"", folderName:"Friends"}, ¬
    {sender:"peter.prouse@normcyber.com", subject:"", folderName:"ISO"}, ¬
    {sender:"", subject:"Singapore Fintech Festival", folderName:"Singapore Fintech Festival"}, ¬
    {sender:"abel.yap@mpinetwork.com", subject:"", folderName:"Singapore"}, ¬
    {sender:"", subject:"Miami", folderName:"Miami"}, ¬
    {sender:"@klgates.com", subject:"", folderName:"KL Gates"}, ¬
    {sender:"@pwc.com", subject:"", folderName:"PWC"}, ¬
    {sender:"MAILER-DAEMON", subject:"", folderName:"Undelivered"}, ¬
    {sender:"@infosecinstitute.com", subject:"", folderName:"Cengage"}, ¬
    {sender:"@cengage.com", subject:"", folderName:"Cengage"}, ¬
    {sender:"@kidsincnurseries.co.uk", subject:"", folderName:"Kids Inc"}, ¬
    {sender:"@Traydstream.com", subject:"", folderName:"Traydstream"}, ¬
    {sender:"@traydstream.com", subject:"", folderName:"Traydstream"}, ¬
    {sender:"@thelogchain.com", subject:"", folderName:"LogChain"}, ¬
    {sender:"dse@docusign.net", subject:"", folderName:"Docusign"}, ¬
    {sender:"dse_NA3@docusign.net", subject:"", folderName:"Docusign"}, ¬
    {sender:"dse@eumail.docusign.net", subject:"", folderName:"Docusign"}, ¬
    {sender:"@cherub.health", subject:"", folderName:"Leslie Dickson"}, ¬
    {sender:"", subject:"Cherub Health", folderName:"Leslie Dickson"}, ¬
    {sender:"@intelleigen.com", subject:"", folderName:"Serena Lim"}, ¬
    {sender:"@bizibody.biz", subject:"", folderName:"Serena Lim"}, ¬
    {sender:"@hsbc.com", subject:"", folderName:"HSBC"}, ¬
    {sender:"", subject:"Case Study", folderName:"TMBLDF"}, ¬
    {sender:"Tendai.Wileman@gstt.nhs.uk", subject:"", folderName:"TMBLDF"}, ¬
    {sender:"rinilaskar@googlemail.com", subject:"", folderName:"TMBLDF"}, ¬
    {sender:"norman.womuhai@hotmail.com", subject:"", folderName:"TMBLDF"}, ¬
    {sender:"s.akin@hotmail.co.uk", subject:"", folderName:"TMBLDF"}, ¬
    {sender:"mirandabrawn@hotmail.com", subject:"", folderName:"TMBLDF"}, ¬
    {sender:"jbconsultingmdp@gmail.com", subject:"", folderName:"TMBLDF"}, ¬
    {sender:"info@tmbdlf.com", subject:"", folderName:"TMBLDF"}, ¬
    {sender:"darren.allaway@gmail.com", subject:"", folderName:"TMBLDF"}, ¬
    {sender:"jonathan.andrews336@gmail.com", subject:"", folderName:"TMBLDF"}, ¬
    {sender:"@charitycommission.gov.uk", subject:"", folderName:"TMBLDF"}, ¬
    {sender:"radhika.rani@hpe.com", subject:"", folderName:"Radhika Rani"}, ¬
    {sender:"stephen.glasper@new-oxford.com", subject:"", folderName:"Stephen Glasper"}, ¬
    {sender:"Glasper", subject:"", folderName:"Stephen Glasper"}, ¬
    {sender:"@londonandpartners.com", subject:"", folderName:"London & Partners"}, ¬
    {sender:"getpostman.com", subject:"", folderName:"Postman"}, ¬
    {sender:"@placedobson.co.uk", subject:"", folderName:"Dobson"}, ¬
    {sender:"@correct-group.co.uk", subject:"", folderName:"Correct"}, ¬
    {sender:"Agamenon@outlook.com", subject:"", folderName:"Correct"}, ¬
    {sender:"@shlegal.com", subject:"", folderName:"Stephenson Harwood"}, ¬
    {sender:"David.Cosway@ICLR.CO.UK", subject:"", folderName:"David Cosway"}, ¬
    {sender:"billing@emea.salesforce.com", subject:"", folderName:"Invoices"}, ¬
    {sender:"@thetimes.co.uk", subject:"", folderName:"The Times"}, ¬
    {sender:"@cgsh.com", subject:"", folderName:"CGSH"}, ¬
    {sender:"@nelsonmullins.com", subject:"", folderName:"Mike Smith"}, ¬
    {sender:"@innovatefinance.com", subject:"", folderName:"Innovate Finance"}, ¬
    {sender:"phelim@hey.com", subject:"", folderName:"Friends"}, ¬
    {sender:"@rocketstudio.ai", subject:"", folderName:"Investment"}, ¬
    {sender:"", subject:"receipt", folderName:"Invoices"}, ¬
    {sender:"invoice", subject:"", folderName:"Invoices"}, ¬
    {sender:"", subject:"Invoice", folderName:"Invoices"}, ¬
    {sender:"", subject:"Payment reminder", folderName:"Invoices"}, ¬
    {sender:"billing@basecamp.com", subject:"", folderName:"Invoices"}, ¬
    {sender:"@credence.co.uk", subject:"", folderName:"Credence"}, ¬
    {sender:"@hoganlovells.com", subject:"", folderName:"HL"}, ¬
    {sender:"sharonlewisboys@gmail.com", subject:"", folderName:"HL"}, ¬
    {sender:"noreply@m.onetrust.com", subject:"Vendor", folderName:"HL"}, ¬
    {sender:"@iottribe.org", subject:"", folderName:"IoTTribe"}, ¬
    {sender:"@allenovery.com", subject:"", folderName:"A&O"}, ¬
    {sender:"harrymryder@gmail.com", subject:"", folderName:"Harry Ryder Personal Email"}, ¬
    {sender:"confluence@lawfairy.atlassian.net", subject:"", folderName:"Concluence Updates"}, ¬
    {sender:"jira@lawfairy.atlassian.net", subject:"", folderName:"Jira Updates"}, ¬
    {sender:"no-reply@heroku.com", subject:"", folderName:"Heroku"}, ¬
    {sender:"bot@notifications.heroku.com", subject:"", folderName:"Heroku Notifications"}, ¬
    {sender:"@hubspot.com", subject:"", folderName:"HubSpot"}, ¬
    {sender:"@alexandria-media.org", subject:"", folderName:"HAL Media"}, ¬
    {sender:"@voidsoftware.com", subject:"", folderName:"HAL Media"}, ¬
    {sender:"T.Kirchmaier@lse.ac.uk", subject:"", folderName:"HAL Media"}, ¬
    {sender:"isabelazenha@gmail.com", subject:"", folderName:"HAL Media"}, ¬
    {sender:"jmhealy@hovione.com", subject:"", folderName:"Hovione"}, ¬
    {sender:"jeremy_2238", subject:"", folderName:"HAL Media"}, ¬
    {sender:"Jeremy Grant", subject:"", folderName:"HAL Media"}, ¬
    {sender:"@bbc.com", subject:"", folderName:"HAL Media"}, ¬
    {sender:"@vistex.com", subject:"", folderName:"HAL Media"}, ¬
    {sender:"amos@biegun.net", subject:"", folderName:"HAL Media"}, ¬
    {sender:"@fieldfisher.com", subject:"", folderName:"HAL Media"}, ¬
    {sender:"@dentons.com", subject:"", folderName:"Dentons"}, ¬
    {sender:"melinda.wallman@macrae.com", subject:"", folderName:"Inbound Recruitment"}, ¬
    {sender:"notifications@monday.com", subject:"", folderName:"Monday Updates"}, ¬
    {sender:"jane.clemetson@clemetson.co.uk", subject:"", folderName:"Jane Clemetson"}, ¬
    {sender:"@anastasiabloom.com", subject:"", folderName:"Friends"}, ¬
    {sender:"Robert.Lawson@uk.bp.com", subject:"", folderName:"Friends"}, ¬
    {sender:"rlawson@mercuria.com", subject:"", folderName:"Friends"}, ¬
    {sender:"rslawson111@outlook.com", subject:"", folderName:"Friends"}, ¬
    {sender:"laura@rosefielddc.com", subject:"", folderName:"Friends"}, ¬
    {sender:"anabhajit@MLAGlobal.com", subject:"", folderName:"Friends"}, ¬
    {sender:"Gavin.Weir@akingump.com", subject:"", folderName:"Friends"}, ¬
    {sender:"Daniel.Levy@Mishcon.com", subject:"", folderName:"Friends"}, ¬
    {sender:"Amy.Edwards@AllenOvery.com", subject:"", folderName:"Friends"}, ¬
    {sender:"julie@juliekimble.com", subject:"", folderName:"Friends"}, ¬
    {sender:"william@nextbigthingconsulting.com", subject:"", folderName:"Potential Supplier"}, ¬
    {sender:"william@nextbigthingconsulting.com", subject:"", folderName:"Potential Supplier"}, ¬
    {sender:"mike@expeditedssl.com", subject:"", folderName:"Potential Supplier"}, ¬
    {sender:"paperlesspost", subject:"", folderName:"Paperless"}, ¬
    {sender:"@Shearman.com", subject:"", folderName:"Shearman"}, ¬
    {sender:"@winston.com", subject:"", folderName:"Winston"}, ¬
    {sender:"jason.ku@pirical.com", subject:"", folderName:"Pirical"}, ¬
    {sender:"@notify.microsoft.com", subject:"", folderName:"Microsoft Notifications"}, ¬
    {sender:"@jeniferswallow.com", subject:"", folderName:"Jenifer Swallow"}, ¬
    {sender:"mirandavilliers", subject:"", folderName:"Jenifer Swallow"}, ¬
    {sender:"jenny.y.chong@googlemail.com", subject:"", folderName:"Jenny Chong"}, ¬
    {sender:"jessicajrowlands@gmail.com", subject:"", folderName:"Jessica Rowlands"}, ¬
    {sender:"@bluevoyant.com", subject:"", folderName:"Bluevoyant"}, ¬
    {sender:"BlueVoyant", subject:"", folderName:"Bluevoyant"}, ¬
    {sender:"Joel Radiven", subject:"", folderName:"Bluevoyant"}, ¬
    {sender:"@jonnyharrisdesign.co.uk", subject:"", folderName:"Videography"}, ¬
    {sender:"michael.smith@sportventuregroup.com", subject:"", folderName:"Mike Smith"}, ¬
    {sender:"@verifile.co.uk", subject:"", folderName:"Verifile"}, ¬
    {sender:"@excellentatlife.com", subject:"", folderName:"Joseph Gerstel"}, ¬
    {sender:"karina.litvack", subject:"", folderName:"Karina Litvack"}, ¬
    {sender:"", subject:"Responsible Exit", folderName:"Karina Litvack"}, ¬
    {sender:"", subject:"Managed Phaseout", folderName:"Karina Litvack"}, ¬
    {sender:"@carbontracker.org", subject:"", folderName:"Karina Litvack"}, ¬
    {sender:"@justice.gov.uk", subject:"", folderName:"MoJ"}, ¬
    {sender:"@africa-legal.com", subject:"", folderName:"MoJ"}, ¬
    {sender:"@businessandtrade.gov.uk", subject:"", folderName:"DBT"}, ¬
    {sender:"@traverssmith.com", subject:"", folderName:"Travers"}, ¬
    {sender:"@Roarb2b.com", subject:"", folderName:"Speaking"}, ¬
    {sender:"meplafi@gmail.com", subject:"", folderName:"Moe Lafi"}, ¬
    {sender:"Pro Bono", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"Support Through", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@adviceni.net", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"s.weinstein@aston.ac.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@phf.org.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@shu.ac.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"ToufiqueH@Duncanlewis.com", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@northyorkslca.org.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"", subject:"Pro Bono", folderName:"Pro Bono"}, ¬
    {sender:"@bright-tide.co.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@lightningreach.org", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@livedexpert.org", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@nfj.org.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@trialview.com", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"Laura.Jones@simmons-simmons.com", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@dobsonsmith.consulting", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"Erika.Pagano@simmons-simmons.com", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@bateswells.co.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"Diane.Sechi@simmons-simmons.com", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@lawcentres.org.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@atjf.org.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"A.Byam@Supportthroughcourt.org", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"abdul@campaignzero.org", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@lawworks.org.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"cerihutton@mac.com", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"amandajfinlay@gmail.com", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@lawforlife.org.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@centralenglandlc.org.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"sharon.blackman@citi.com", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@mayorsfundforlondon.org.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@justice.org.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@phf.org.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@refuaid.org", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@bristolrefugeerights.org", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@inhouseprobono.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@supportthroughcourt.org", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@socialenterprise.org.uk", subject:"", folderName:"Pro Bono"}, ¬
    {sender:"@city.ac.uk", subject:"", folderName:"City University"}, ¬
    {sender:"akehinde", subject:"", folderName:"Anthonia Kehinde"}, ¬
    {sender:"leslie@techsingaporeadvocates.com", subject:"", folderName:"Sarma"}, ¬
    {sender:"sudeep.sarma", subject:"", folderName:"Sarma"}, ¬
    {sender:"@sohoworks.com", subject:"", folderName:"Soho Works"}, ¬
    {sender:"@ico.org.uk", subject:"", folderName:"ICO"}, ¬
    {sender:"@yuenlaw.com.sg", subject:"", folderName:"Yuen Law"}, ¬
    {sender:"@startup-o.com", subject:"", folderName:"Sarma"}, ¬
    {sender:"@abundanceinvestment.com", subject:"", folderName:"Abundance"}, ¬
    {sender:"elisabeth.cowell@secnewgate.co.uk", subject:"", folderName:"SECNewgate AI"}, ¬
    {sender:"@osborneclarke.com", subject:"", folderName:"Osborne Clarke"}, ¬
    {sender:"bmaamebonsu@gmail.com", subject:"", folderName:"Mentoring"}, ¬
    {sender:"larissa.rea@redlawrecruitment.com", subject:"", folderName:"Mentoring"}, ¬
    {sender:"Gurdeep.Plahe@IrwinMitchell.com", subject:"", folderName:"Mentoring"}, ¬
    {sender:"Sahibdeep.Singh@shlegal.com", subject:"", folderName:"Mentoring"}, ¬
    {sender:"Maame Bonsu", subject:"", folderName:"Mentoring"}, ¬
    {sender:"danormond@outlook.com", subject:"", folderName:"Mentoring"}, ¬
    {sender:"shaalini.daya@citi.com", subject:"", folderName:"Mentoring"}, ¬
    {sender:"eimear.oboyle@outlook.com", subject:"", folderName:"Mentoring"}, ¬
    {sender:"eimear.oboyle.2@credit-suisse.com", subject:"", folderName:"Mentoring"}, ¬
    {sender:"elias.boehmer@googlemail.com", subject:"", folderName:"Mentoring"}, ¬
    {sender:"jasmine_ashley@hotmail.com", subject:"", folderName:"Jasmine Ashley"}, ¬
    {sender:"Mark.Dalton@conv-ex.com", subject:"", folderName:"Mark Dalton"}, ¬
    {sender:"Paul.Martin@mourant.com", subject:"", folderName:"Mourant"}, ¬
    {sender:"@majoto.io", subject:"", folderName:"Majoto"}, ¬
    {sender:"meg@byfieldconsultancy.com", subject:"", folderName:"Meganne"}, ¬
    {sender:"ncrasner@crasnerconsulting.com", subject:"", folderName:"Friends"}, ¬
    {sender:"patrick.caron-delion@investec.com", subject:"", folderName:"Friends"}, ¬
    {sender:"Matthew Fisher", subject:"", folderName:"Matthew Fisher"}, ¬
    {sender:"Matthew.Fisher@lw.com", subject:"", folderName:"Matthew Fisher"}, ¬
    {sender:"matthew.fisher@lw.com", subject:"", folderName:"Matthew Fisher"}, ¬
    {sender:"matthewfisher@gmx.co.uk", subject:"", folderName:"Matthew Fisher"}, ¬
    {sender:"@winterflood.com", subject:"", folderName:"Winterflood"}, ¬
    {sender:"f.morris@accenture.com", subject:"", folderName:"Tech Contacts"}, ¬
    {sender:"tobi.ajala@techtee.co", subject:"", folderName:"Tech Contacts"}, ¬
    {sender:"christina@blacklawsconsulting.com", subject:"", folderName:"Tech Contacts"}, ¬
    {sender:"Tim.Howard@oceaninfinity.com", subject:"", folderName:"Tech Contacts"}, ¬
    {sender:"clementine.fox@luminance.com", subject:"", folderName:"Tech Contacts"}, ¬
    {sender:"shana.simmons@everlaw.com", subject:"", folderName:"Tech Contacts"}, ¬
    {sender:"shana@everlaw.com", subject:"", folderName:"Tech Contacts"}, ¬
    {sender:"manu@lexsolutions.com", subject:"", folderName:"Tech Contacts"}, ¬
    {sender:"Daniel.Hoadley@Mishcon.com", subject:"", folderName:"Tech Contacts"}, ¬
    {sender:"lc@nroditi.com", subject:"", folderName:"Tech Contacts"}, ¬
    {sender:"sam@officeanddragons.com", subject:"", folderName:"Tech Contacts"}, ¬
    {sender:"srin@peoplerobots.com", subject:"", folderName:"Tech Contacts"}, ¬
    {sender:"@whatifinnovation.com", subject:"", folderName:"Tech Contacts"}, ¬
    {sender:"@foundersintelligence.com", subject:"", folderName:"Tech Contacts"}, ¬
    {sender:"acomyns@brownadvisory.com", subject:"", folderName:"Tech Contacts"}, ¬
    {sender:"kevinlim@temasek.com.sg", subject:"", folderName:"Crypto"}, ¬
    {sender:"@technation.io", subject:"", folderName:"TechNation"}, ¬
    {sender:"sam@palmbrokers.com", subject:"", folderName:"Friends"}, ¬
    {sender:"sebjenks@gmail.com", subject:"", folderName:"Sebastian Jenks"}, ¬
    {sender:"seb.jenks@resolvedisputes.online", subject:"", folderName:"Sebastian Jenks"}, ¬
    {sender:"@ianjenks.com", subject:"", folderName:"Ian Jenks"}, ¬
    {sender:"hubspot.com", subject:"", folderName:"HubSpot"}, ¬
    {sender:"Alex.Tamlyn@dlapiper.com", subject:"", folderName:"PMG"}, ¬
    {sender:"@cwt.com", subject:"", folderName:"Cadwalader"}, ¬
    {sender:"@Shearman.com", subject:"", folderName:"Shearman"}, ¬
    {sender:"@cosmonauts.biz", subject:"", folderName:"Cosmonauts"}, ¬
    {sender:"Future Lawyer", subject:"", folderName:"Cosmonauts"}, ¬
    {sender:"@stanhillcapital.com", subject:"", folderName:"Quantinuum"}, ¬
    {sender:"@quantinuum.com", subject:"", folderName:"Quantinuum"}, ¬
    {sender:"@bkam.ma", subject:"", folderName:"Bank of Morocco"}, ¬
    {sender:"@twobirds.com", subject:"", folderName:"Bird & Bird"}, ¬
    {sender:"notifications@3.basecamp.com", subject:"", folderName:"Basecamp Notifications"}, ¬
    {sender:"support@basecamp.com", subject:"", folderName:"Basecamp Support"}, ¬
    {sender:"nkoemtzo@gmail.com", subject:"", folderName:"Koem"}, ¬
    {sender:"@allenandgledhill.com", subject:"", folderName:"Allen & Gledhill"}, ¬
    {sender:"@papertrailapp.com", subject:"", folderName:"Papertrail"}, ¬
    {sender:"@legaltech-talk.com", subject:"", folderName:"Legal Tech Talk"}, ¬
    {sender:"lseg.com", subject:"", folderName:"LSEG"}, ¬
    {sender:"@nortonrosefulbright.com", subject:"", folderName:"Norton Rose"}, ¬
    {sender:"@foundercatalyst.com", subject:"", folderName:"Founder Catalyst"}, ¬
    {sender:"reference@rent4sure.co.uk", subject:"", folderName:"References"}, ¬
    {sender:"@maxwellbond.co.uk", subject:"", folderName:"References"}, ¬
    {sender:"@veroscreening.com", subject:"", folderName:"References"}, ¬
    {sender:"@referencing.zinc.work", subject:"", folderName:"References"}, ¬
    {sender:"@wongpartnership.com", subject:"", folderName:"Wong"}, ¬
    {sender:"@gsk.com", subject:"", folderName:"GSK"}, ¬
    {sender:"@viivhealthcare.com", subject:"", folderName:"GSK"}, ¬
    {sender:"@nautadutilh.com", subject:"", folderName:"Nauta"}, ¬
    {sender:"@jll.com", subject:"", folderName:"JLL"}, ¬
    {sender:"@matrix-advisors.com", subject:"", folderName:"Investment"}, ¬
    {sender:"@insightpartners.com", subject:"", folderName:"Investment"}, ¬
    {sender:"@octopusventures.com", subject:"", folderName:"Investment"}, ¬
    {sender:"@greshamhouse.com", subject:"", folderName:"Investment"}, ¬
    {sender:"@haatch.com", subject:"", folderName:"Investment"}, ¬
    {sender:"@molten.vc", subject:"", folderName:"Investment"}, ¬
    {sender:"David.Sharratt@sc.com", subject:"", folderName:"Standard Chartered"}, ¬
    {sender:"@salesforce.com", subject:"", folderName:"Salesforce"}, ¬
    {sender:"salesforce.com", subject:"", folderName:"Salesforce"}, ¬
    {sender:"postmarkapp.com", subject:"", folderName:"Postmark"}, ¬
    {sender:"support@scoutapm.com", subject:"", folderName:"Scout"}, ¬
    {sender:"support@stripe.com", subject:"", folderName:"Stripe"}, ¬
    {sender:"notifications@stripe.com", subject:"", folderName:"Stripe"}, ¬
    {sender:"atlassian.com", subject:"", folderName:"Atlassian"}, ¬
    {sender:"do-not-reply@trello.com", subject:"", folderName:"Trello"}, ¬
    {sender:"support@monday.com", subject:"", folderName:"Monday"}, ¬
    {sender:"no_reply@monday.com", subject:"", folderName:"Monday"}, ¬
    {sender:"security@post.xero.com", subject:"", folderName:"Xero"}, ¬
    {sender:"@kandji.io", subject:"", folderName:"Kandji"}, ¬
    {sender:"@heroku.com", subject:"", folderName:"Heroku"}, ¬
    {sender:"@hmtreasury.gov.uk", subject:"", folderName:"HMT"}, ¬
    {sender:"thetrainline.com", subject:"", folderName:"Trainline"}, ¬
    {sender:"trainline.com", subject:"", folderName:"Trainline"}, ¬
    {sender:"Salesforce", subject:"", folderName:"Salesforce"}, ¬
    {sender:"nulab.com", subject:"", folderName:"Nulab"}, ¬
    {sender:"calendly.com", subject:"", folderName:"Calendly"}, ¬
    {sender:"@google.com", subject:"", folderName:"Google"}, ¬
    {sender:"@sentry.io", subject:"", folderName:"Sentry"}, ¬
    {sender:"system@myactiv.online", subject:"", folderName:"ISO"}, ¬
    {sender:"support@myactiv.co.uk", subject:"", folderName:"ISO"}, ¬
    {sender:"apple.com", subject:"", folderName:"Apple"}, ¬
    {sender:"Apple", subject:"", folderName:"Apple"}, ¬
    {sender:"Daniel.Jenkins", subject:"", folderName:"Daniel Jenkins"}, ¬
    {sender:"keystone", subject:"", folderName:"Keystone"}, ¬
    {sender:"@dara5.com", subject:"", folderName:"Dara5"}, ¬
    {sender:"tickets@universe.com", subject:"", folderName:"Tickets"}, ¬
    {sender:"@londontechweek.com", subject:"", folderName:"Tickets"}, ¬
    {sender:"@eventdata.co.uk", subject:"", folderName:"Tickets"}, ¬
    {sender:"danieljewelfilm@gmail.com", subject:"", folderName:"Daniel Jewel"}, ¬
    {sender:"amakhani@transperfect.com", subject:"", folderName:"Al-Karim (Transperfect)"}, ¬
    {sender:"andrew.wood@aimpathy.co.uk", subject:"", folderName:"Andrew Wood"}, ¬
    {sender:"vestd.com", subject:"", folderName:"Vestd"}, ¬
    {sender:"@100ximpact.org", subject:"", folderName:"100x"}, ¬
    {sender:"ved.nathwani@gmail.com", subject:"", folderName:"Ved Nathwani"}, ¬
    {sender:"wise.com", subject:"", folderName:"Wise"}, ¬
    {sender:"@wise.com", subject:"", folderName:"Wise"}, ¬
    {sender:"", subject:"Singapore", folderName:"Singapore"}, ¬
    {sender:"", subject:"GSK", folderName:"Singapore"}¬
  }
      
      -- Iterate through each account
      repeat with accountName in accountNames
      set myAccount to account accountName
            
            -- Filter conditions for the current account
            repeat with aCondition in emailConditions
                set theInbox to mailbox "INBOX" of myAccount
                set theMessages to every message of theInbox
                log "Found " & (count of theMessages) & " messages in the Inbox of " & accountName

                set targetSender to sender of aCondition
                set targetSubject to subject of aCondition
                set targetFolderName to folderName of aCondition
                
                -- Check if target folder exists, if not, create it
                try
                  set targetFolder to mailbox targetFolderName of myAccount
                on error
                  try
                      set targetFolder to make new mailbox with properties {name:targetFolderName} at myAccount
                      delay 1 -- Short delay to ensure folder creation
                  on error creationError
                      log "Failed to create folder: " & targetFolderName & ". Error: " & creationError
                  end try
                end try

                -- Iterate through messages in the Inbox
                repeat with aMessage in theMessages
                  -- Check conditions based on whether sender or subject is specified
                  if (targetSender is not equal to "" and sender of aMessage contains targetSender) or (targetSubject is not equal to "" and subject of aMessage contains targetSubject) then
                      -- Attempt to move the message to the target folder
                      try
                          move aMessage to targetFolder
                      on error errMsg
                          log "Error moving message: " & errMsg
                      end try
                  end if
                end repeat
            end repeat
        end repeat
    end tell
  APPLESCRIPT

  # Create a temporary file
  Tempfile.open('file_lawfairy_emails') do |f|
    f.write(apple_script_content)
    f.close
    # Execute the AppleScript from the temporary file
    system "osascript #{f.path}"
  end

  puts "Filed emails based on conditions."
end


desc "File iCloud emails based on conditions"
task :file_icloud_emails do |t|

  # -- set accountNames to {"iCloud", "Lawfairy"} -- Adjust with your account names
  apple_script_content = <<-APPLESCRIPT
    tell application "Mail"
    -- Define accounts and conditions
    set accountNames to {"iCloud"} -- Adjust with your account names
    set emailConditions to {¬
      {sender:"arbrown@cgsh.com", subject:"", folderName:"CG"}, ¬
      {sender:"vestd.com", subject:"", folderName:"Vestd"}, ¬
      {sender:"jobs-listings@linkedin.com", subject:"", folderName:"Junk"}, ¬
      {sender:"@idr.co", subject:"", folderName:"Junk"}, ¬
      {sender:"hit-reply@linkedin.com", subject:"", folderName:"Junk"}, ¬
      {sender:"customercare@emails.net-a-porter.com", subject:"", folderName:"Junk"}, ¬
      {sender:"customercare@net-a-porter.com", subject:"", folderName:"Junk"}, ¬
      {sender:"premier@net-a-porter.com", subject:"", folderName:"Junk"}, ¬
      {sender:"no-reply@getcircuit.com", subject:"", folderName:"Junk"}, ¬
      {sender:"stokeaudi.co.uk", subject:"", folderName:"Junk"}, ¬
      {sender:"oj-partners.co.uk", subject:"", folderName:"Junk"}, ¬
      {sender:"@mkwcreative.com", subject:"", folderName:"Junk"}, ¬
      {sender:"mariya.patel@ynap.com", subject:"", folderName:"Junk"}, ¬
      {sender:"@iqnetwork.co", subject:"", folderName:"Junk"}, ¬
      {sender:"news@hodinkee.com", subject:"", folderName:"Junk"}, ¬
      {sender:"gary.rycroft@jajsolicitors.co.uk", subject:"", folderName:"Nizam"}, ¬
      {sender:"nizam@broachi.com", subject:"", folderName:"Nizam"}, ¬
      {sender:"David.Briggs@coutts.com", subject:"", folderName:"Coutts"}, ¬
      {sender:"coutts.com", subject:"", folderName:"Coutts"}, ¬
      {sender:"@lawfairy.com", subject:"", folderName:"LawFairy"}, ¬
      {sender:"raj.panasar@lawfairy.com", subject:"", folderName:"Raj forwards"}, ¬
      {sender:"raj.panasar@hoganlovells.com", subject:"", folderName:"Raj forwards"}, ¬
      {sender:"raj.panasar@yahoo.com", subject:"", folderName:"Raj forwards"}, ¬
      {sender:"raj.panasar@gmail.com", subject:"", folderName:"Raj forwards"}, ¬
      {sender:"rbodderick@gmail.com", subject:"", folderName:"Raj forwards"}, ¬
      {sender:"raj.panasar@me.com", subject:"", folderName:"Raj forwards"}, ¬
      {sender:"hoganlovells.com", subject:"", folderName:"HL"}, ¬
      {sender:"hoganlovells", subject:"", folderName:"HL"}, ¬
      {sender:"Audi", subject:"", folderName:"Audi"}, ¬
      {sender:"ruksana.broachi@icloud.com", subject:"", folderName:"Ruksana"}, ¬
      {sender:"simranobhi@gmail.com", subject:"", folderName:"Simran"}, ¬
      {sender:"@sohohouse.com", subject:"", folderName:"Soho House"}, ¬
      {sender:"@smugmug.com", subject:"", folderName:"Smug Mug"}, ¬
      {sender:"coutts", subject:"", folderName:"Coutts"}, ¬
      {sender:"Zayn Hussain", subject:"", folderName:"Quantinuum"}, ¬
      {sender:"@molten.vc", subject:"", folderName:"LawFairy"}, ¬
      {sender:"@lawworks.org.uk", subject:"", folderName:"LawFairy"}, ¬
      {sender:"@Shearman.com", subject:"", folderName:"LawFairy"}, ¬
      {sender:"@shearman.com", subject:"", folderName:"LawFairy"}, ¬
      {sender:"anisaibrahim01@gmail.com", subject:"", folderName:"Anisa"}, ¬
      {sender:"@sra.org.uk", subject:"", folderName:"SRA"}, ¬
      {sender:"lawson_debbie@hotmail.com", subject:"", folderName:"Friends"}, ¬
      {sender:"smclinden@btinternet.com", subject:"", folderName:"Friends"}, ¬
      {sender:"julie@juliekimble.com", subject:"", folderName:"Friends"}, ¬
      {sender:"andrewjhurwitz@gmail.com", subject:"", folderName:"Friends"}, ¬
      {sender:"andyhurwitz@hotmail.com", subject:"", folderName:"Friends"}, ¬
      {sender:"laura@rosefielddc.com", subject:"", folderName:"Friends"}, ¬
      {sender:"laura@thedivorcehub.co.uk", subject:"", folderName:"Friends"}, ¬
      {sender:"Scott Senecal", subject:"", folderName:"Friends"}, ¬
      {sender:"Aseet Dalvi", subject:"", folderName:"Friends"}, ¬
      {sender:"@kiddrapinet.co.uk", subject:"", folderName:"Ruksana"}, ¬
      {sender:"@gs.com", subject:"", folderName:"Goldman"}, ¬
      {sender:"@fedex.com", subject:"", folderName:"Shopping"}, ¬
      {sender:"Kinga Turek", subject:"", folderName:"Ruksana"}, ¬
      {sender:"broar012@rbwm.org.uk", subject:"", folderName:"Ruksana"}, ¬
      {sender:"ncrasner@crasnerconsulting.com", subject:"", folderName:"Friends"}, ¬
      {sender:"ncrasner@crasnercapital.com", subject:"", folderName:"Friends"}, ¬
      {sender:"mrporter.com", subject:"", folderName:"Mr Porter"}, ¬
      {sender:"Safia Panasar", subject:"", folderName:"Safia"}, ¬
      {sender:"@deloitte.com", subject:"", folderName:"Deloitte"}, ¬
      {sender:"james@apexlifestyle.co.uk", subject:"", folderName:"James Harfoot"}, ¬
      {sender:"drhornebilling@gmail.com", subject:"", folderName:"Maya"}, ¬
      {sender:"@stonebridge", subject:"", folderName:"Insurance"}, ¬
      {sender:"@klslaw.co.uk", subject:"", folderName:"Insurance"}, ¬
      {sender:"bniland@cgsh.com", subject:"", folderName:"Tax"}, ¬
      {sender:"jtwynam@cgsh.com", subject:"", folderName:"Tax"}, ¬
      {sender:"@placedobson.co.uk", subject:"", folderName:"Dobson"}, ¬
      {sender:"simonmwalters@icloud.com", subject:"", folderName:"LawFairy"}, ¬
      {sender:"louise@aztec-interior-design.co.uk", subject:"", folderName:"Home"}, ¬
      {sender:"@hrsjoinery.co.uk", subject:"", folderName:"Home"}, ¬
      {sender:"mmacmillen@cgsh.com", subject:"", folderName:"Tax"}, ¬
      {sender:"@colmancoyle.com", subject:"", folderName:"Probate"}, ¬
      {sender:"lastpass.com", subject:"", folderName:"Tech"}, ¬
      {sender:"evernote.com", subject:"", folderName:"Evernote"}, ¬
      {sender:"application.support@ie.edu", subject:"", folderName:"References"}, ¬
      {sender:"jm@thedealteam.com", subject:"", folderName:"Business Development"}, ¬
      {sender:"karina.litvack@gmail.com", subject:"", folderName:"Friends"}, ¬
      {sender:"gilead yeffett", subject:"", folderName:"Gilead"}, ¬
      {sender:"gilead@practica-ltd.com", subject:"", folderName:"Gilead"}, ¬
      {sender:"Nikki Kalsi", subject:"", folderName:"Nikki"}, ¬
      {sender:"Nikki Panasar", subject:"", folderName:"Nikki"}, ¬
      {sender:"safia.panasar@icloud.com", subject:"", folderName:"Safia"}, ¬
      {sender:"maya.panasar", subject:"", folderName:"Maya"}, ¬
      {sender:"ruksana.broachi@me.com", subject:"", folderName:"Ruksana"}, ¬
      {sender:"Hannah Budd", subject:"", folderName:"Hannah Budd"}, ¬
      {sender:"Kelly.Giambrone@keystonelaw.co.uk  ", subject:"", folderName:"Hannah Budd"}, ¬
      {sender:"hamdeepbhinder@gmail.com", subject:"", folderName:"Humpty"}, ¬
      {sender:"info@cgdp.com", subject:"", folderName:"Dentist"}, ¬
      {sender:"cambridgequantum.com", subject:"", folderName:"Quantinuum"}, ¬
      {sender:"isokinetic.com", subject:"", folderName:"Isokinetic"}, ¬
      {sender:"Isokinetic", subject:"", folderName:"Isokinetic"}, ¬
      {sender:"@toynbeehall.org.uk", subject:"", folderName:"Toynbee Hall"}, ¬
      {sender:"HODINKEE Shop", subject:"", folderName:"Hodinkee"}, ¬
      {sender:"@uk.ey.com", subject:"", folderName:"Tax"}, ¬
      {sender:"@net-a-porter.com", subject:"", folderName:"NAP"}, ¬
      {sender:"@ynap.com", subject:"", folderName:"NAP"}, ¬
      {sender:"justgiving.com", subject:"", folderName:"Charity"}, ¬
      {sender:"Tim.Quayle@matchesfashion.com", subject:"", folderName:"Matches"}, ¬
      {sender:"gchakim@yahoo.com", subject:"", folderName:"Friends"}, ¬
      {sender:"", subject:"DX20", folderName:"Audi"}¬
        }
          

        -- Iterate through each account
        repeat with accountName in accountNames
            set myAccount to account accountName
            
            -- Filter conditions for the current account
            repeat with aCondition in emailConditions
                set theInbox to mailbox "INBOX" of myAccount
                set theMessages to every message of theInbox
                log "Found " & (count of theMessages) & " messages in the Inbox of " & accountName

                set targetSender to sender of aCondition
                set targetSubject to subject of aCondition
                set targetFolderName to folderName of aCondition
                
                -- Check if target folder exists, if not, create it
                try
                    set targetFolder to mailbox targetFolderName of myAccount
                on error
                    try
                        set targetFolder to make new mailbox with properties {name:targetFolderName} at myAccount
                        delay 1 -- Short delay to ensure folder creation
                    on error creationError
                        log "Failed to create folder: " & targetFolderName & ". Error: " & creationError
                    end try
                end try


                
                -- Iterate through messages in the Inbox
                repeat with aMessage in theMessages
                    -- Check conditions based on whether sender or subject is specified
                    if (targetSender is not equal to "" and sender of aMessage contains targetSender) or (targetSubject is not equal to "" and subject of aMessage contains targetSubject) then
                        -- Attempt to move the message to the target folder
                        try
                            move aMessage to targetFolder
                        on error errMsg
                            log "Error moving message: " & errMsg
                        end try
                    end if
                end repeat
            end repeat
        end repeat
    end tell
  APPLESCRIPT

  # Create a temporary file
  Tempfile.open('file_icloud_emails') do |f|
    f.write(apple_script_content)
    f.close
    # Execute the AppleScript from the temporary file
    system "osascript #{f.path}"
  end

  puts "Filed emails based on conditions."
end




desc "Mark emails as unread based on complex criteria from a local JSON file"
task :mark_as_unread, [:file_name] do |t, args|
  require 'json'
  
  file_path = File.join(File.dirname(__FILE__), args[:file_name])
  
  # Load criteria from the local JSON file
  criteria_hash = JSON.parse(File.read(file_path))

  subject = criteria_hash["subject"] || ""
  account_name = criteria_hash["account_name"] || "iCloud" # Replace with your actual account name
  mailbox = criteria_hash["mailbox"] || "INBOX" # Make sure this matches the exact mailbox name
  
  apple_script = <<-APPLESCRIPT
    tell application "Mail"
      set theMessages to every message of mailbox "#{mailbox}" of account "#{account_name}" whose subject contains "#{subject}"
      repeat with msg in theMessages
        set read status of msg to false
      end repeat
    end tell
  APPLESCRIPT

  system "osascript -e '#{apple_script}'"
  puts "Marked emails as unread with subject containing '#{subject}' in '#{mailbox}' of '#{account_name}'."
end

desc "Mark emails as read based on complex criteria from a local JSON file"
task :mark_as_read, [:file_name] do |t, args|
  require 'json'
  
  file_path = File.join(File.dirname(__FILE__), args[:file_name])
  
  # Load criteria from the local JSON file
  criteria_hash = JSON.parse(File.read(file_path))

  subject = criteria_hash["subject"] || ""
  account_name = criteria_hash["account_name"] || "iCloud" # Use the account name that worked previously
  mailbox = criteria_hash["mailbox"] || "INBOX"
  
  apple_script = <<-APPLESCRIPT
    tell application "Mail"
      set theMessages to every message of mailbox "#{mailbox}" of account "#{account_name}" whose subject contains "#{subject}"
      repeat with msg in theMessages
        set read status of msg to true
      end repeat
    end tell
  APPLESCRIPT

  system "osascript -e '#{apple_script}'"
  puts "Marked emails as read with subject containing '#{subject}' in '#{mailbox}' of '#{account_name}'."
end

