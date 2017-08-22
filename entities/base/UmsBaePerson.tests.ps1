###########################################################################
# Check whether UmsUEAbstractEntityInstantiationException are thrown
###########################################################################

# Retrieve test document
$_testDocument = Get-TestDocument "Music_Composer"

# Test 1: Instantiate abstract entity class UmsBaePerson
$_test = New-TestItem "Forbid instantiation of abstract entity class UmsBaePerson" "UmsBaePerson"
try { New-Object -Type UmsBaePerson -ArgumentList $_testDocument.DocumentElement | Out-Null }
catch [UmsUEAbstractEntityInstantiationException] { $_test.Passed($_.Exception) }
catch { $_test.Failed($_.Exception) }
$_test.Failed("No exception raised.")
$_test