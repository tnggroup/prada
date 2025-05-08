#!/usr/bin/env nextflow

params.in = "$baseDir/testInput.txt"

/*
 * This is a test
 */
process generate {

	input:
    path testInput

    output:
    stdout
    
    """
    #!/bin/bash
    cat $testInput
    echo 1
    echo 2
    echo 3
    """
}

/*
 * Do something
 */
process reverse {

    input:
    stdin

    output:
    path 'test.out'

    """
    #!/bin/bash
    myVar = `cat`
    echo $myVar > 'test.out';
    """
}

/*
 * Define the workflow
 */
workflow {
    generate(params.in) \
      | reverse \
      | view
}
