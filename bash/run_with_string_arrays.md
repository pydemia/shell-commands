```bash
WORKDIR="packages"
PKG_LIST="op-core op-tabular"
PKG_ARRAY=($(echo "${PKG_LIST}" | tr ' ' '\n'))
echo $PKG_ARRAY
PKG_DIRS=( "${PKG_ARRAY[@]/#/\"${WORKDIR}/}" )
echo "$PKG_DIRS"
#`echo $(echo ${PKG_DIRS[@]}) | tr ' ' ','`  # raw: packages/op-core,packages/op-tabular
PKG_PATTERN=( "${PKG_DIRS[@]/%//*\"}" )
echo "$PKG_PATTERN"
PKG_INCLUDE=`echo $(echo ${PKG_PAT[@]}) | tr ' ' ','`
echo "$PKG_INCLUDE"

coverage report -i --include `sed -e 's/^"//' -e 's/"$//' -e 's/","/,/' <<<"$PKG_INCLUDE"` --omit "test/*" 

################################
ARRAY=( one two three )
(IFS=,; eval echo prefix_\{"${ARRAY[*]}"\}_suffix)

STRING="one two three"
eval echo prefix_\{${STRING// /,}\}_suffix

################################
WORKDIR="packages"
PKG_LIST="op-core op-tabular"
INCLUDED=$(eval echo \\\"${WORKDIR}/\{${PKG_LIST// /,}\}/*\\\"| tr ' ' ',')
coverage report -i --include `sed -e 's/^"//' -e 's/"$//' -e 's/","/,/' <<<"$INCLUDED"` --omit "test/*" 
################################
```

```bash
WORKDIR="packages"
PKG_LIST="op-core op-tabular"
OMT_LIST="test"
PKG_ARRAY=($(echo "${PKG_LIST}" | tr ' ' '\n'))
PKG_FORMATTED=( $(echo ${PKG_ARRAY[*]}|sed "s/\(\b[^ ]\+\)/\"${WORKDIR}\1\"/g") )
OMT_ARRAY=($(echo "${ING_LIST}" | tr ' ' '\n'))
OMT_FORMATTED=( $(echo ${ING_ARRAY[*]}|sed "s/\(\b[^ ]\+\)/\"${WORKDIR}\1\"/g") )
coverage report --ignore-errors \
    --include=`echo $(echo ${PKG_FORMATTED[@]}) | tr ' ' ','` \
    --omit=`echo $(echo ${OMT_FORMATTED[@]}) | tr ' ' ','`
```

```bash
WORKDIR="packages"
PKG_LIST="op-core op-tabular"
OMT_LIST="test"
PKG_ARRAY=($(echo "${PKG_LIST}" | tr ' ' '\n'))
PKG_DIRS=( "${PKG_ARRAY[@]/#/./${WORKDIR}/}" )
pip install `echo ${PKG_DIRS[@]:-./${WORKDIR}}`
```
