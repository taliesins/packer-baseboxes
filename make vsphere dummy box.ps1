$dummy_box_path = 'vsphere-dummy.box'
$dummy_path = 'vsphere_dummy_box'

if (test-path $dummy_box_path){
	remove-item $dummy_box_path -Force
}

cd $dummy_path
if (test-path $dummy_box_path){
	remove-item $dummy_box_path -Force
}

tar cvzf $dummy_box_path ./metadata.json
mv $dummy_box_path ..