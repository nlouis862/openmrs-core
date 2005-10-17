<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Form Entry" otherwise="/login.jsp" />

<%@ include file="/WEB-INF/template/header.jsp" %>

<script src='/openmrs/dwr/interface/DWRPatientService.js'></script>
<script src='/openmrs/dwr/engine.js'></script>
<script src='/openmrs/dwr/util.js'></script>

<script>

	var timeout;
	var searchOn;
	
	function showSearch() {
		findPatient.style.display = "";
		patientListing.style.display = "none";
		patientSummary.style.display = "none";
		selectForm.style.display = "none";
	}
	
	function searchBoxChange(event, obj) {
		if (event.altKey == false &&
			event.ctrlKey == false &&
			((event.keyCode >= 32 && event.keyCode <= 127) || event.keyCode == 8)) {
				clearTimeout(timeout);
				timeout = setTimeout("updatePatients()",obj.id=="identifier" ? 1000 : 500);
		}
	}
	
	function choose(obj) {
		if (obj.id == "identifier") {
			searchOn = "identifier";
			//identifierBox.enabled = true;
			//givenNameBox.enabled  = false;
			//familyNameBox.enabled = false;
		}
		else {
			searchOn = "name";
			//identifierBox.enabled = false;
			//givenNameBox.enabled  = true;
			//familyNameBox.enabled = true;
		}
	}
	
	function updatePatients() {
	    DWRUtil.removeAllRows("patientTableBody");
	    var identifier = searchOn == "identifier" ? identifierBox.value : "";
	    var givenName = givenNameBox.value;
	    var familyName = familyNameBox.value;
	    DWRPatientService.findPatients(fillTable, identifier, givenName, familyName);
	    patientListing.style.display = "";
	    return false;
	}
	
	var getId			= function(obj) { return obj.patientId; };
	var getIdentifier	= function(obj) { 
			var str = "";
			str += "<a href=javascript:selectPatient(" + obj.patientId + ")>";
			str += obj.identifier;
			str += "</a>";
			return str;
		};
	var getGivenName	= function(obj) { return obj.givenName;  };
	var getFamilyName	= function(obj) { return obj.familyName; };
	var getGender		= function(obj) { return obj.gender; };
	var getRace			= function(obj) { return obj.race; };
	var getBirthdate	= function(obj) { 
			var str = '';
					str += obj.birthdate.getMonth() + '-';
			str += obj.birthdate.getDate() + '-';
			str += (obj.birthdate.getYear() + 1900);
			
			if (obj.birthdateEstimated)
				str += " (?)";
			
			return str;
		};
	var getMothersName  = function(obj) { return obj.mothersName;  };
	
	function fillTable(patientListItem) {
	    DWRUtil.addRows("patientTableBody", patientListItem, [ getId, getIdentifier, getGivenName, getFamilyName, getGender, getRace, getBirthdate, getMothersName]);
	}
	
	function selectPatient(patientId) {
		findPatient.style.display = "none";
		patientSummary.style.display = "";
		selectForm.style.display = "";
		selectFormForm.patientId.value = patientId;
		DWRPatientService.getPatient(fillPatientDetails, patientId);
	}
	
	function fillPatientDetails(patient) {
		var html = "<b class='boxHeader'>Patient Information</b>";
		html = html + "<a href='editPatient?patientId=" + patient.patientId + "' style='float:right'>Edit patient</a>";
		html = html + "<b>Name</b>:" + patient.givenName + " " + patient.familyName + "<br />";
		html = html + "<b>Gender</b>:" + patient.gender + "<br />";
		html = html + "<b>Address</b>:" + patient.address + "<br />...";
		html = html + "<br /><input type='button' value='Switch Patient' onClick='showSearch(); patientListing.style.display = \"\";'>";
		patientSummary.innerHTML = html;
	}

</script>

<h2>Form Entry</h2>

<div id="findPatient">
	<b class="boxHeader">1. Find a Patient</b>
	<div class="box">
		<br>
		<form id="findPatientForm" onSubmit="updatePatients(); return false;">
			<table>
				<tr>
					<td>Identifier</td>
					<td><input type="text" id="identifier" onFocus="choose(this)" onKeyUp="searchBoxChange(event, this)"></td>
				</tr>
				<tr><td></td><td><i>or</i></tr>
				<tr>
					<td>First Name</td>
					<td><input type="text" id="givenName" onFocus="choose(this)" onKeyUp="searchBoxChange(event, this)"></td>
				</tr>
				<tr>
					<td>Last Name</td>
					<td><input type="text" id="familyName" onFocus="javascript:choose(this)" onKeyUp="searchBoxChange(event, this)"></td>
				</tr>
			</table>
			<!-- <input type="submit" value="Search" onClick="return updatePatients();"> -->
		</form>
		<div id="patientListing">
			<table id="patientTable" width="100%">
			 <thead>
				 <tr>
				 	<th>Id</th>
				 	<th>Identifier</th>
				 	<th>Given Name</th>
				 	<th>Family Name</th>
				 	<th>Gender</th>
				 	<th>Race</th>
				 	<th>BirthDate</th>
				 	<th>Mother's Name</th>
				 </tr>
			 </thead>
			 <tbody id="patientTableBody">
			 </tbody>
			 <tfoot>
			 	<tr><td colspan="8"><i>Don't see the patient?</i> Use the <a href="createPatientForm.jsp">Create New Patient Form</a></td></tr>
			 </tfoot>
			</table>
		</div>
	</div>
</div>

<div id="patientSummary">
</div>

<br />

<b class="boxHeader">2. Select a form</b>
<div id="selectForm" class="box">
	<br />
	<form id="selectFormForm" method="post" action="<%= request.getContextPath() %>/formDownload">
		
		<table>
			<tr>
				<td><input type="radio" name="formType" value="adultInitial" id="adultInitial"></td>
				<td><label for="adultInitial">Adult Initial</label></td>
			</tr>
			<tr>
				<td><input type="radio" name="formType" value="adultReturn" id="adultReturn"></td>
				<td><label for="adultReturn">Adult Return</label></td>
			</tr>
			<tr>
				<td><input type="radio" name="formType" value="pedInitial" id="pedInitial"></td>
				<td><label for="pedInitial">Ped Initial</label></td>
			</tr>
			<tr>
				<td><input type="radio" name="formType" value="pedReturn" id="pedReturn"></td>
				<td><label for="pedReturn">Ped Return</label></td>
			</tr>
		</table>
		<input type="hidden" name="patientId" id="patientId" value="">
		<input type="submit" value="Download Form">
	</form>
</div>

<script>

	var patientListing= document.getElementById("patientListing");
	var selectForm    = document.getElementById("selectForm");
	var findPatient   = document.getElementById("findPatient");
	var identifierBox = document.getElementById("identifier");
	var givenNameBox  = document.getElementById("givenName");
	var familyNameBox = document.getElementById("familyName");
	var patientTableBody= document.getElementById("patientTableBody");
	var findPatientForm = document.getElementById("findPatientForm");
	var selectFormForm  = document.getElementById("selectFormForm");
	var patientSummary  = document.getElementById("patientSummary");
	
	showSearch();
	
	<request:existsAttribute name="patientId">
		selectPatient(request.getAttribute("patientId"));
	</request:existsAttribute>
</script>

<%@ include file="/WEB-INF/template/footer.jsp" %>
