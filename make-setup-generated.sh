#! /bin/sh
#
# Generate version and metadata preamble for the document
#

DATESTR=${DATESTR:-`cat REVISION-DATE 2>/dev/null`}

VERSION=`echo "$1"| sed -e 's/virtio-v//' -e 's/-.*//'`

# If a second argument is passed we extract what we can from git
# metadata (closest version tag) and local tree status. This
# allows us to build an unofficial draft and tag it appropriately.
#
# The formal build process skips this.
if ! test -z "$2"; then
    # base date on now
    DATESTR=$(date +'%d %B %Y')
    COMMIT=$(git describe --tags --match 'v[0-9]*' HEAD 2>/dev/null)
    # fallback if we have no version tags for reference
    if test -z "$COMMIT"; then
        COMMIT=$(git rev-parse --short HEAD)
    fi
    # Finally check if we have un-committed changes in the tree
    if ! git diff-index --quiet HEAD -- ; then
        COMMIT="$COMMIT (dirty)"
    fi

    STAGE=draft
    STAGENAME="Unofficial Draft (git @ $COMMIT)"
    WORKINGDRAFT=
else
    # These are all stages mandated by the OASIS process
    case "$1" in
        *-wd*)
	    STAGE=wd
	    STAGENAME="Working Draft"
	    WORKINGDRAFT=`basename "$1" | sed 's/.*-wd//'`
	    ;;
        *-os*)
	    STAGE=os
	    STAGENAME="OASIS Standard"
	    WORKINGDRAFT=""
	    ;;
        *-csd*)
	    STAGE=csd
	    WORKINGDRAFT=`basename "$1" | sed 's/.*-csd//'`
	    STAGENAME="Committee Specification Draft $WORKINGDRAFT"
	    ;;
        *-csprd*)
	    STAGE=csprd
	    WORKINGDRAFT=`basename "$1" | sed 's/.*-csprd//'`
	    STAGENAME="Committee Specification Draft $WORKINGDRAFT"
	    STAGEEXTRATITLE=" / \newline Public Review Draft $WORKINGDRAFT"
	    STAGEEXTRA=" / Public Review Draft $WORKINGDRAFT"
	    ;;
        *-cs*)
	    STAGE=cs
	    WORKINGDRAFT=`basename "$1" | sed 's/.*-cs//'`
	    STAGENAME="Committee Specification $WORKINGDRAFT"
	    ;;
        *)
	    echo Unknown doc type >&2
	    exit 1
    esac
fi

#Prepend OASIS unless already there or unofficial
case "$STAGENAME" in
	OASIS*|Unofficial*)
		OASISSTAGENAME="$STAGENAME"
		;;
	*)
		OASISSTAGENAME="OASIS $STAGENAME"
		;;
esac

cat > setup-generated.tex <<EOF
% define VIRTIO Working Draft number and date
\newcommand{\virtiorev}{$VERSION}
\newcommand{\virtioworkingdraftdate}{$DATESTR}
\newcommand{\virtioworkingdraft}{$WORKINGDRAFT}
\newcommand{\virtiodraftstage}{$STAGE}
\newcommand{\virtiodraftstageextra}{$STAGEEXTRA}
\newcommand{\virtiodraftstageextratitle}{$STAGEEXTRATITLE}
\newcommand{\virtiodraftstagename}{$STAGENAME}
\newcommand{\virtiodraftoasisstagename}{$OASISSTAGENAME}
EOF
