#!/bin/bash 

set -euo pipefail


for content_file in content/*; do
	
	name=$(basename $content_file .md)
	build_file="build/$name.html"

	links_file="links/$name.links.md"
	[ -f $links_file ] || links_file='links/back.links.md'

	cat html/html.head.txt > $build_file
	cmark $links_file >> $build_file
	echo '</div>' >> $build_file
	cmark $content_file >> $build_file
	echo '</body>' >> $build_file

done
