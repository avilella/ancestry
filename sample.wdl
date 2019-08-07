#sample.wdl
workflow iadmix {
  call runancestry
}

#This task calls GATK's tool, HaplotypeCaller in normal mode. This tool takes a pre-processed 
#bam file and discovers variant sites. These raw variant calls are then written to a vcf file.
task runancestry {
  File RUNANCESTRY
  String sampleName
  String minmq
  String pathancestry
  File inputBAM
  File freqsfile

  String docker_WGS

  Int machine_mem_gb = 8
  Int command_mem_gb = machine_mem_gb - 2

  command {
    python ${RUNANCESTRY} --addchr --minmq ${minmq} -f ${freqsfile} --bam ${inputBAM} -o ${sampleName}.output --path ${pathancestry}
  }
  output {
    File ancestryOUT = "${sampleName}.output.ancestry.out"
  }

#  command {
#    java -jar --java-options "-Xmx${command_mem_gb}G" ${GATK} \
#      -T HaplotypeCaller \
#      -R ${RefFasta} \
#      -I ${inputBAM} \
#      -o ${sampleName}.raw.indels.snps.vcf
#  }
#  output {
#    File rawVCF = "${sampleName}.raw.indels.snps.vcf"
#  }

  runtime {
        docker: docker_WGS
        memory: "${machine_mem_gb}G"
        cpu: 4
        maxRetries: 3
    }
}
