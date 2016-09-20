ASSUMPTIONS: Docker/git/cmake are installed on the system this script will be used... And also the account has root privileges

INPUT PARAMETERS: None
HOW TO EXECUTE: ./automation.sh
OUTPUT: TEST SUCCESSFUL if all the steps pass else TEST FAILED..
	Along with above output, we also get build, deployment and test logs in build.log, deploy.log and test.log respectively

DESIGN DOC: Design.txt

DOC ON MY ROLE: Devops_Role.txt

DOC ON CHOICES: Tools.txt


TROUBLESHOOTING:
	1. FAILED TO RUN .sh file.. Make sure the file has executable permissions..
	Use "chmod 755 automation.sh" to change file permissions
	2. GIT NOT RECOGNIZED.. install git using "apt-get install git"
	3. BUILD FAILED.. install build essentials using "apt-get install build-essentials"
		and "apt-get install cmake"


