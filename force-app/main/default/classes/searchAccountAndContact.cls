global without sharing class searchAccountAndContact {
    public static List<Account> accCandidates;
    public static String currentCriteria;
    public static wrapperAccountAndContact searchAccountAndContactCall(LeadReceiver.LeadRecord RecordData) {    
       wrapperAccountAndContact wrapper = new wrapperAccountAndContact();
        if(RecordData != null ){
            String postalCodeRaw = RecordData.zip;
            String postalCode = (postalCodeRaw != null && postalCodeRaw != '') ? postalCodeRaw + '%' : null;
            String companyNameRaw = RecordData.Company;
            String companyName = (companyNameRaw != null && companyNameRaw != '') ? '%' + companyNameRaw + '%' : null;
            String phone = RecordData.Phone;
            String country = RecordData.Country;
            String state = RecordData.State;
            String city = RecordData.City;
           String address = RecordData.Street;
            String website = RecordData.Website;
            String emailAddress = RecordData.Email;

            // Build dynamic SOQL to avoid illegal bind expressions in WHERE
            String base = 'SELECT BillingCountry, BillingStreet, BillingState, BillingCity, BillingPostalCode, Website, Phone, Name, '
                + 'Id, '
                + '(SELECT Id, Email FROM Contacts WHERE Email = \'' + (emailAddress != null ? String.escapeSingleQuotes(emailAddress) : '') + '\' LIMIT 1) '
                + 'FROM Account WHERE ';

            List<String> conds = new List<String>();
            if(String.isNotBlank(phone)){
                conds.add('Phone = ' + '\'' + String.escapeSingleQuotes(phone) + '\'');
            }
            if((country == 'US' || country == 'CA') && address != null && address != '' && state != null && city != null && postalCode != null){
                conds.add('(BillingStreet = ' + '\'' + address + '\'' + ' AND BillingState = ' + '\'' + state + '\'' + ' AND BillingCity = ' + '\'' + city + '\'' + ' AND BillingPostalCode LIKE ' + '\'' + postalCode + '\'' + ' AND BillingCountry = ' + '\'' + country + '\')') ;
                // close paren added implicitly
            }
            if(country == 'US' && companyName != null && postalCode != null){
                conds.add('(Name LIKE ' + '\'' + companyName + '\'' + ' AND BillingPostalCode LIKE ' + '\'' + postalCode + '\'' + ' AND BillingCountry = ' + '\'' + country + '\')') ;
            }
            if(country == 'CA' && companyName != null){
                conds.add('(Name LIKE ' + '\'' + companyName + '\'' + ' AND BillingState = ' + '\'' + state + '\'' + ' AND BillingCountry = ' + '\'' + country + '\')') ;
            }
            if(country != 'US' && country != 'CA' && companyName != null){
                conds.add('(Name LIKE ' + '\'' + companyName + '\'' + ' AND BillingCountry = ' + '\'' + country + '\')') ;
            }
            if((country == 'US' || country == 'CA') && String.isNotBlank(website) && postalCode != null){
                conds.add('(Website = ' + '\'' + String.escapeSingleQuotes(website) + '\'' + ' AND BillingPostalCode LIKE ' + '\'' + String.escapeSingleQuotes(postalCode) + '\'' + ' AND BillingCountry = ' + '\'' + country + '\')') ;
            }
            if(country != 'US' && country != 'CA' && website != null && website != ''){
                conds.add('(Website = ' + '\'' + website + '\'' + ' AND BillingCountry = ' + '\'' + country + '\')') ;
            }

            if(conds.isEmpty()){
                // nothing to query
                accCandidates = new List<Account>();
            } else {
                String whereClause = String.join(conds, ' OR ');
                String finalQuery = base + whereClause + ' LIMIT 50';
                System.debug('finalQuery: ' + finalQuery);
                accCandidates = Database.query(finalQuery);
            }

            Account accRec;
            Contact conRec;
            String Accountcriteria;
            String resultMessage = 'No action taken';
          If(accCandidates != null && !accCandidates.isEmpty()){              
            for(Account acc : accCandidates){
                if(phone != null && phone != '' && acc.Phone != null && acc.Phone == phone){
                    accRec = acc;                  
                    currentCriteria = 'Phone Number';
                } else if((country == 'US' || country == 'CA') && address != null && address != '' && acc.BillingStreet == address && acc.BillingState == state && acc.BillingCity == city && postalCodeRaw != null && postalCodeRaw != '' && acc.BillingPostalCode != null && acc.BillingPostalCode.startsWith(postalCodeRaw) && acc.BillingCountry == country){
                    accRec = acc;
                    currentCriteria = 'Address';
                } else if(country == 'US' && companyNameRaw != null && companyNameRaw != '' && acc.Name != null && acc.Name.contains(companyNameRaw) && postalCodeRaw != null && postalCodeRaw != '' && acc.BillingPostalCode != null && acc.BillingPostalCode.startsWith(postalCodeRaw) && acc.BillingCountry == 'US'){
                   accRec = acc;
                    currentCriteria = 'Name,Postal Code and Country';
                } else if(country == 'CA' && companyNameRaw != null && companyNameRaw != '' && acc.Name != null && acc.Name.contains(companyNameRaw) && acc.BillingState == state){
                   accRec = acc;
                    currentCriteria = 'Name and State';
                } else if((country == 'US' || country == 'CA') && website != null && website != '' && acc.Website == website && postalCodeRaw != null && postalCodeRaw != '' && acc.BillingPostalCode != null && acc.BillingPostalCode.startsWith(postalCodeRaw)){
                    accRec = acc;
                    currentCriteria = 'Domain and PostalCode';
                } else if(country != 'US' && country != 'CA' && companyNameRaw != null && companyNameRaw != '' && acc.Name != null && acc.Name.contains(companyNameRaw) && acc.BillingCountry == country){
                   accRec = acc;
                    currentCriteria = 'Name, Country';
                } else if(country != 'US' && country != 'CA' && website != null && website != '' && acc.Website == website && acc.BillingCountry == country){
                    accRec = acc;
                    currentCriteria = 'Domain And Country';
                }

                If(accRec != null && string.isNotBlank(currentCriteria) ){
                    conRec = accRec.Contacts.isEmpty() ? null : accRec.Contacts[0];
                }
             }
         }

            if(accRec != null){
                Account accToSave = accRec;
                if(companyNameRaw != null && companyNameRaw != ''){
                    accToSave.Name = companyNameRaw;
                }
                if(address != null && address != ''){
                    accToSave.BillingStreet = address;
                }
                if(city != null && city != ''){
                    accToSave.BillingCity = city;
                }
                if(state != null && state != ''){
                    accToSave.BillingState = state;
                }
                if(postalCodeRaw != null && postalCodeRaw != ''){
                    accToSave.BillingPostalCode = postalCodeRaw;
                }
                if(country != null && country != ''){
                    accToSave.BillingCountry = country;
                }
                if(phone != null && phone != ''){
                    accToSave.Phone = phone;
                }
                if(website != null && website != ''){
                    accToSave.Website = website;
                }

                if(conRec != null){
                    if(emailAddress != null && emailAddress != ''){
                        conRec.Email = emailAddress;
                    }
                    if(conRec.LastName == null || conRec.LastName == ''){
                        String contactLastName = 'Unknown';
                        if(emailAddress != null && emailAddress.contains('@')){
                            contactLastName = emailAddress.split('@')[0];
                        } else if(companyNameRaw != null && companyNameRaw != ''){
                            contactLastName = companyNameRaw;
                        }
                        conRec.LastName = contactLastName;
                    }
                    update accToSave;
                    update conRec;
                    wrapper.accRec = accToSave.Id;
                    wrapper.conRec = conRec.Id;
                    wrapper.currentCriteria = currentCriteria;
                    wrapper.resultMessage = 'Account and Contact updated';
                } else {
                    Contact newContact = new Contact(
                        AccountId = accToSave.Id,
                        Email = emailAddress,
                        LastName = (emailAddress != null && emailAddress.contains('@')) ? emailAddress.split('@')[0] : (companyNameRaw != null && companyNameRaw != '' ? companyNameRaw : 'Unknown')
                    );
                    update accToSave;
                    insert newContact;
                    wrapper.accRec = accToSave.Id;
                    wrapper.conRec = newContact.Id;
                    wrapper.currentCriteria = currentCriteria;
                    wrapper.resultMessage = 'Contact created and Account updated';
                }
            } else {
                Account newAccount = new Account(
                    Name = (companyNameRaw != null && companyNameRaw != '') ? companyNameRaw : 'New Account',
                    BillingStreet = address,
                    BillingCity = city,
                    BillingState = state,
                    BillingPostalCode = postalCodeRaw,
                    BillingCountry = country,
                    Phone = phone,
                    Website = website
                );
                insert newAccount;
                Contact newContact = new Contact(
                    AccountId = newAccount.Id,
                    Email = emailAddress,
                    LastName = (emailAddress != null && emailAddress.contains('@')) ? emailAddress.split('@')[0] : (companyNameRaw != null && companyNameRaw != '' ? companyNameRaw : 'Unknown')
                );
                insert newContact;
                wrapper.accRec = newAccount.Id;
                wrapper.conRec = newContact.Id;
                wrapper.currentCriteria = currentCriteria;
                wrapper.resultMessage = 'Account and Contact created';
            }
            
        }
        return wrapper;
    }
    
    global class LeadRecord {

        public String PhoneNumberSupplied;
        public String PhoneNumberResearched;
        public String CompanyName;
        public String City;
        public String State;
        public String Address;
        public String PostalCode;
        public String Country;
        public String Website;
        public String emailaddress;

    }     
}