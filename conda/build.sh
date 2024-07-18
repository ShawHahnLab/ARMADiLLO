#!/usr/bin/env bash

# Modeling this roughly off the igblast bioconda recipe

SHARE_DIR=$PREFIX/share/ARMADiLLO

mkdir -p $PREFIX/bin

# $SHARE_DIR contains the actual ARMADiLLO binary and also the required data
# files. A wrapper will be installed into $PREFIX/bin that points to those data
# files.
mkdir -p $SHARE_DIR/bin

make -f Makefile.conda
mv ARMADiLLO $SHARE_DIR/bin
cp Mutability.csv $SHARE_DIR
cp Substitution.csv $SHARE_DIR

name=ARMADiLLO
cat >"$PREFIX/bin/$name" <<EOF
#!/bin/sh

# Wrapper for ARMADiLLO that points to bundled Mutability.csv and
# Substitution.csv by default.

args=("\$@")

needs_mut=true
needs_sub=true
for arg in "\${args[@]}"; do
	if [[ "\$arg" == "-m" ]]; then
		needs_mut=false
	elif [[ "\$arg" == "-s" ]]; then
		needs_sub=false
	fi
done

DIR="\${CONDA_PREFIX}/share/ARMADiLLO"
if \$needs_mut; then
	args+=("-m" "\${DIR}/Mutability.csv")
fi
if \$needs_sub; then
	args+=("-s" "\${DIR}/Substitution.csv")
fi
exec "\${DIR}/bin/$name" "\${args[@]}"
EOF
chmod +x "$PREFIX/bin/$name"
