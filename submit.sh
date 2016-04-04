echo "Enter next submit comment"
read answer
if [ "$answer" == '' ] ; 
then
    echo "nothing"
else
	git add -A && git commit -m $answer
	git push origin master
	git tag $answer
	git push --tag
	
	folder=${PWD##*/} 
	pod trunk push $folder.podspec
fi




