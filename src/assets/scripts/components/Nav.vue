<template>
    <nav class="navbar is-primary" role="navigation" aria-label="main navigation">
        <div class="container">
            <div class="navbar-brand">
                <a class="navbar-item" href="/">
                    <h2>watzon.tech</h2>
                </a>

                <a role="button" class="navbar-burger" :class="{ 'is-active': isActive }" aria-label="menu" :aria-expanded="isActive" href="#" v-on:click.prevent="toggleActive">
                    <span aria-hidden="true"></span>
                    <span aria-hidden="true"></span>
                    <span aria-hidden="true"></span>
                </a>
            </div>

            <div class="navbar-menu" :class="{ 'is-active': isActive }">

                <div class="navbar-end">
                    <a class="navbar-item" href="https://github.com/watzon">
                        <span class="icon">
                            <i class="fab fa-github"></i>
                        </span>
                        <span class="is-hidden-desktop">Github</span>
                    </a>
                    <a class="navbar-item" href="https://twitter.com/_watzon">
                        <span class="icon">
                            <i class="fab fa-twitter"></i>
                        </span>
                        <span class="is-hidden-desktop">Twitter</span>
                    </a>
                    <a class="navbar-item" href="https://dribbble.com/watzon">
                        <span class="icon">
                            <i class="fab fa-dribbble"></i>
                        </span>
                        <span class="is-hidden-desktop">Dribbble</span>
                    </a>
                    <a class="navbar-item" href="https://keybase.io/watzon">
                        <span class="icon">
                            <i class="fab fa-keybase"></i>
                        </span>
                        <span class="is-hidden-desktop">Keybase</span>
                    </a>
                </div>
            </div>
        </div>
    </nav>
</template>

<script>
export default {
    data: function () {
       return  {
           isActive: false
       }
    },
    methods: {
        toggleActive: function(e) {
            this.isActive = !this.isActive
        }
    }
}
</script>