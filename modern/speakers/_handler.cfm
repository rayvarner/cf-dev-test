<cfscript>
	// simulate request context
	if( !structKeyExists( variables, "rc" ) ){
		rc = {};
	}

	structAppend( rc, form );
	structAppend( rc, url );

	if( !structKeyExists( rc, 'method' ) ) {
		// and redirect back to the list view
		location( '/modern/speakers/index.cfm', false );
	}

	// switch on the passed in method
	switch( rc.method ) {

		// *** UPDATE ***
		case 'update':
			// TODO - get the speaker bean
			rc.speakerObj = new models.beans.SpeakerBean();
			// TODO - set speakerID of the speaker bean from obfuscated and encrypted value passed in form
			rc.speakerObj.setSpeakerID( rc.speakerObj.getDecUid( rc[ rc.speakerObj.getUidHash( 'form' ) ], 'form' ) );

			// get the CSRF token key and token passed in the form
			rc.token = {
				key = rc[ rc.speakerObj.getTokenKeyHash() ],
				value = rc[ rc.speakerObj.getTokenHash() ]
			};
			// verify the CSRF token is valid
			if( !CSRFVerifyToken( rc.token.value, rc.token.key ) ) {
				// it isn't, force the user to login again
				location( '/modern/', false );
			}

			// check if the speakerID is a zero guid
			if( rc.speakerObj.getSpeakerUID() eq application.zeroGuid ) {
				// TODO - it is, set it to a new generated guid value
				rc.speakerObj.setSpeakerUid( application.securityService.getGUID() );
				// set createdOn to now()
				rc.speakerObj.setCreatedOn( now() );
			} else {
				// TODO - it isn't, populate the speaker bean from the database
				rc.speakerObj = application.speakerService.getSpeakerByID( rc.speakerObj.getSpeakerID() );
			}
			rc.speakerObj.setSpeakerTypeID( trim( rc.speakerTypeID ) );

			//finish setting the properties on the speaker bean

			// TODO - set the value of firstName passed in the form
			rc.speakerObj.setFirstName( trim( rc.firstName ) );
			// TODO - set the value of lastName passed in the form
			rc.speakerObj.setLastName( trim( rc.lastName ) );
			// TODO - set the value of jobTitle passed in the form
			rc.speakerObj.setJobTitle( trim( rc.jobTitle ) );
			// TODO - set the value of company passed in the form
			rc.speakerObj.setCompany( trim( rc.company ) );
			// TODO - set the value of email passed in the form
			rc.speakerObj.setEmail( trim( rc.email ) );
			// TODO - set the value of bio passed in the form
			rc.speakerObj.setBio( trim( rc.bio ) );
			// TODO - set the value of hideSpeaker passed in the form
			rc.speakerObj.setHideSpeaker( trim( rc.hideSpeaker ) );
			// TODO - set the value of updatedOn to now()
			rc.speakerObj.setUpdatedOn( now() );
			// TODO - set isActive to true
			rc.speakerObj.setIsActive( true );

			// TODO - save the speaker bean to the database
			application.speakerService.saveSpeaker( rc.speakerObj );

			// clear all cached query data using a function from speakerService
			application.speakerService.clearAllCachedSpeakerQueries();

			// and redirect back to the list view
			location( '/modern/speakers/index.cfm', false );

		break;

		// *** DEACTIVATE ***
		case 'deactivate':
			// get the speaker bean
			rc.speakerObj = new models.beans.SpeakerBean();
			// set speakerID of the speaker bean from obfuscated and encrypted value passed in url
			rc.speakerObj.setSpeakerID( rc.speakerObj.getDecUid( rc[ rc.speakerObj.getUidHash( 'url' ) ], 'url' ) );
			// populate the speaker from the database
			rc.speakerObj = application.speakerService.getSpeakerByID( rc.speakerObj.getSpeakerID() );
			// set isActive to false
			rc.speakerObj.setIsActive( false );
			// save the speaker bean to the database
			application.speakerService.saveSpeaker( rc.speakerObj );

			// and redirect back to the list view
			location( '/modern/speakers/index.cfm', false );
		break;

		// *** REACTIVATE ***
		case 'reactivate':
			// get the speaker bean
			rc.speakerObj = new models.beans.SpeakerBean();
			// set speakerID of the speaker bean from obfuscated and encrypted value passed in url
			rc.speakerObj.setSpeakerID( rc.speakerObj.getDecUid( rc[ rc.speakerObj.getUidHash( 'url' ) ], 'url' ) );
			// populate the speaker from the database
			rc.speakerObj = application.speakerService.getSpeakerByID( rc.speakerObj.getSpeakerID() );
			// set isActive to true
			rc.speakerObj.setIsActive( true );
			// save the speaker bean to the database
			application.speakerService.saveSpeaker( rc.speakerObj );

			// and redirect back to the list view
			location( '/modern/speakers/index.cfm', false );
		break;

		// *** DATATABLE ***
		case 'datatable':

			// disable debug output
			setting showdebugoutput=false;

			// get the speaker bean
			rc.speakerObj = new models.beans.SpeakerBean();

			// setup variables for looping through the query
			rc.returnStruct = {};
			rc.speakerArr = [];
			rc.orderBy = '';
			rc.orderByArr = [];
			// check if we have a valid isActive passed in
			if( !structKeyExists( rc, 'isActive')
				|| !isBoolean( rc.isActive )
			) {
				// we don't, set it to true to show only active records
				rc.isActive = true;
			}

			// set the columns to return in this query
			rc.returnColumns = 'speakerID, speakerUid, speakerTypeID, firstName, lastName, jobTitle, company, email, bio';

			// set the columns that will be sortable in the datatable
			rc.sortableColumns = 'speakerID,speakerTypeID,firstName,lastName,jobTitle,company,email,bio';

			// ensure a search value was passed from the datatable
			if( !structKeyExists( rc, 'search[value]') ) {
				// it wasn't, set it to blank
				rc[ 'search[value]' ] = '';
			}

			// loop through the total sortable columns in the datatable
			for( rc.idx = 0; rc.idx < listLen( rc.sortableColumns ); rc.idx++ ) {

				// ensure an order value was passed from the datatable
				if( !structKeyExists( rc, 'order[#rc.idx#][dir]' ) ) {
					// it wasn't, set it to asc order
					rc[ 'order[#rc.idx#][dir]' ] = 'asc';
				}

				// ensure an order column was passed from the datatable
				if( structKeyExists( rc, 'order[#rc.idx#][column]' ) ) {
					rc.orderByArr.append( listGetAt( rc.sortableColumns, rc[ 'order[#rc.idx#][column]' ] + 1 ) );

				}
			}

			// check if our sort array has length
			if( arrayLen( rc.orderByArr ) ) {

				// it does, loop through the sort array
				for( rc.idx = 1; rc.idx <= arrayLen( rc.orderByArr ); rc.idx++ ) {

					// add this column and sort order to the order by clause
					rc.orderBy &= rc.orderByArr[ rc.idx ] & ' ' & rc[ 'order[#rc.idx - 1#][dir]' ];
					if( !rc.idx eq arrayLen( rc.orderByArr ) ) {
						rc.orderBy &= ', ';
					}

				}

			// otherwise
			} else {

				// set the default order by clause column
				rc.orderBy = '#listFirst( rc.sortableColumns )# asc';

			}

			// get the total Speaker records
			rc.totalRecords = application.speakerService.getSpeakerRecordCount( isActive = rc.isActive );

			// get a query of Speaker records
			rc.qGetSpeakers = application.speakerService.filter(
				isActive = rc.isActive,
				orderBy = rc.orderBy,
				returnColumns = rc.returnColumns,
				pagination = true,
				start = rc.start,
				length = rc.length,
				search = rc[ 'search[value]' ],
				cache = false, // TBD: Set this to true in production
				clearCache = structKeyExists( rc, 'clearCache' ) ? rc.clearCache : false
			);

			// loop through the Speaker records
			for( rc.speaker in rc.qGetSpeakers ) {

				// set up a struct to hold this row of data
				rc.speakerStruct = {};

				// encrypt the speakerID value for this row
				rc.encId = application.securityService.dataEnc( rc.speaker.speakerID, 'url' );

				// add the speakerID column to the datatable
				rc.speakerStruct['speakerID'] = rc.speaker.speakerID;
				// add the speakerTypeID column to the datatable
				rc.speakerStruct['speakerTypeID'] = rc.speaker.speakerTypeID;
				// add the firstName column to the datatable
				rc.speakerStruct['firstName'] = rc.speaker.firstName;
				// add the lastName column to the datatable
				rc.speakerStruct['lastName'] = rc.speaker.lastName;
				// add the jobTitle column to the datatable
				rc.speakerStruct['jobTitle'] = rc.speaker.jobTitle;
				// add the company column to the datatable
				rc.speakerStruct['company'] = rc.speaker.company;
				// add the email column to the datatable
				rc.speakerStruct['email'] = rc.speaker.email;
				// add the bio column to the datatable
				rc.speakerStruct['bio'] = rc.speaker.bio;

				// build the edit anchor for this row
				rc.speakerStruct['actions'] = '<a href="/modern/speakers/edit.cfm?#rc.speakerObj.getUidHash( 'url' )#=#rc.encId#" class="btn btn-primary btn-sm" data-toggle="tooltip" data-placement="top" title="Edit">Edit</a>';

				// check if we're displaying active records
				if( rc.isActive ) {

					// we are, build the deactivate modal anchor for this row
					rc.speakerStruct['actions'] &= '<span data-id="#rc.encId#" data-toggle="modal" data-target="##speakerModal" data-entity="[PLACEHOLDER]"><a href="##speakerModal" class="btn btn-danger btn-sm" data-toggle="tooltip" data-placement="top" title="Delete">Delete</a></span>';

				// otherwise
				} else {

					// we're not, build the reactivate anchor for this row
					rc.speakerStruct['actions'] &= '<a href="/modern/speakers/_handler.cfm?method=reactivate&#rc.speakerObj.getUidHash( 'url' )#=#rc.encId#" class="btn btn-primary" data-toggle="tooltip" data-placement="top" title="Reactivate">Reactivate</a>';
				}

				// add this row to the array
				rc.speakerArr.append( rc.speakerStruct );

			}

			// set datatable required values
			rc.returnStruct[ 'draw' ] = rc.draw;
			rc.returnStruct[ 'recordsTotal' ] = rc.totalRecords;
			rc.returnStruct[ 'recordsFiltered' ] = len( rc[ 'search[value]' ] ) ? rc.qGetSpeakers.recordCount : rc.totalRecords;
			rc.returnStruct[ 'data' ] = rc.speakerArr;

			// render as JSON to the datatable
			writeOutput( serializeJSON( rc.returnStruct ) ) ;
		break;
	}

</cfscript>