echo "getting $url${rev:+ ($rev)} into $out"

hg clone --insecure "$url" hg-clone

hg archive -q$subrepoClause -y ${rev:+-r "$rev"} --cwd hg-clone $out
rm -f $out/.hg_archival.txt
