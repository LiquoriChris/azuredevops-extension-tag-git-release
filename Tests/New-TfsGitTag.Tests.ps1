Describe 'New-TfsGitTag' {
    Mock Invoke-RestMethod {
        return 200 
    }
    It 'Should return a status code of 200' {
        Invoke-RestMethod -Uri www.hii.usf.edu -UseBasicParsing |Should BeExactly 200  
    }
    it 'Should be Mocked' {
		$Params = @{
			CommandName = 'Invoke-RestMethod'
			Times = 1
			Exactly = $true
		}
		Assert-MockCalled @Params
	}
}