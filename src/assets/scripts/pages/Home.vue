<template>
    <div>
        <navbar></navbar>

        <div class="container">
            <section class="section what-is-this">
                <h1 class="title">What this is?</h1>
                <p>
                    This is a tool to obfuscate IPTC special instructions encoded into some Facebook images. Note, we're not removing 
                    the instruction, but simply shuffling the bits around so as to make it useless to facebook for tracking. This 
                    works by scanning the images bits for a special instruction that starts with <strong>FBMD</strong> which stands
                    for Facebook Message Digest. Following those 4 bytes is a 6 byte sequence that tells us the length of the
                    tracking hash (either 72 or 80 bytes) and then a unique hash which I assume is stored somewhere in Facebook's
                    database matching the image to an uploader.
                </p>
                <p>
                    This tool simply takes the tracking hash's bytes and shuffles them around, thereby making them useless to 
                    Facebook for tracking purposes. There is also a slight possibility that the hash will be shuffled to match 
                    that of another image which would mess with Facebook's tracking algorithm, or less likely, that Facebook won't 
                    know how to deal with the messed up tracking data. Either way, they will no longer be able to track the
                    image.
                </p>
            </section>

            <section class="section how-to-use">
                <h1 class="title">How do I use it?</h1>
                <p>
                    Just drop the images you wish to fix into the box below. When you're ready to process them just click the "Process" 
                    button and wait. Your images will be modified and packed into a zip file for you to download. Easy peasy.
                </p>
            </section>

            <section class="section image-dropzone">
                <div class="process-button">
                    <button class="button is-primary" v-on:click="doProcess">
                        <div class="icon">
                            <div class="fas fa-sync"></div>
                        </div>
                        <span>Process</span>
                    </button>
                </div>

                <vue2-dropzone ref="dropzone" id="dropzone" :options="dropzoneOptions"></vue2-dropzone>

                <div v-if="downloadLink && !error" class="download-link">
                    <article class="message is-success">
                        <div class="message-body">
                            <h2 class="subtitle">Images Processed Successfully</h2>

                            <div class="link">
                                <a class="button is-success" :href="downloadLink">Click Here to Download</a>
                            </div>

                            <p>
                                This link will be valid until midnight.
                            </p>
                        </div>
                    </article>
                </div>

                <div v-if="error" class="process-error">
                    <article class="message is-danger">
                        <div class="message-body">
                            {{ error }}
                        </div>
                    </article>
                </div>
            </section>
        </div>
    </div>
</template>

<script>
import Nav from '../components/Nav.vue'
import vue2Dropzone from 'vue2-dropzone'
import 'vue2-dropzone/dist/vue2Dropzone.min.css'

export default {
    name: 'home',
    components: {
        navbar: Nav,
        vue2Dropzone: vue2Dropzone
    },
    data: function () {
        return {
            dropzoneOptions: {
                url: '/images',
                thumbnailWidth: 150,
                maxFilesize: 2,
                acceptedFiles: "image/*",
                autoProcessQueue: false
            },
            downloadLink: null,
            error: null
        }
    },
    methods: {
        doProcess: async function () {
            let dz = this.$refs.dropzone
            let files = dz.getQueuedFiles()
            let data = new FormData()
            
            for (let [index, file] of files.entries()) {
                console.log(file)
                data.append('file', files[index])
            }

            fetch('/images', {
                method: 'POST',
                mode: 'same-origin',
                // cache: 'only-if-cached',
                credentials: 'same-origin',
                headers: {
                    'Accept': '*/*'
                },
                body: data
            }).then(async (res) => {
                if (res.status < 299) {
                    let download = await res.text()
                    let thisUrl = `${window.location.protocol}//${window.location.host}`

                    this.error = null
                    this.downloadLink = `${thisUrl}/download/${download}`
                    
                    this.$refs.dropzone.removeAllFiles()
                    window.scrollTo(0, document.body.scrollHeight)
                } else {
                    let error = await res.text()
                    this.error = error
                }
            }).catch(err => {
                this.error = err
            })
        }
    }
}
</script>
