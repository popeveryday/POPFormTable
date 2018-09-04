echo "Enter version"
read version

echo "Enter next submit comment"
read comment

echo "Allow warning? (y/[n])"
read alw



if [ "$version" == '' ] ; 
then
    echo "nothing"
else
	if [ "$comment" == '' ] ; 
	then
    	git add -A && git commit -m $version
	else
		git add -A && git commit -m "'$comment'"
	fi

	
	git push origin master
	git tag $version
	git push --tag
	
	folder=${PWD##*/} 

	if [ "$alw" == 'y' ] ; 
	then
	    pod trunk push $folder.podspec --allow-warnings
	else
		pod trunk push $folder.podspec
	fi

	
fi




