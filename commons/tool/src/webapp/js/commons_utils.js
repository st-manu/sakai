commons.utils = {

    POST_WITHOUT_COMMENTS_STYLE: 'commons-post-without-comments',
    POST_WITH_COMMENTS_STYLE: 'commons-post-with-comments',
    OGP_IMAGE_REGEX: /og:image" content=["']([^"]*)["']\s*\//,
    TWITTER_IMAGE_REGEX: /twitter:image" content="([^"]*)"/,
    OGP_TITLE_REGEX: /og:title" content="([^"]*)"/,
    OGP_DESCRIPTION_REGEX: /og:description" content="([^"&#]*)"/,
    OGP_SITE_NAME_REGEX: /og:site_name" content="([^"]*)"/,
    AUTHOR_REGEX: /author" content="([^"]*)"/,

    fromHtml: function (html) {
        return html.replace(/<br>/g, '\n');
    },
    toHtml: function (text) {
        return text.replace(/\r\n|\n|\r/g, '<br>');
    },
    getOGPMarkup: function (url, callback) {

        var self = this;

        $.get('/direct/commons/getUrlMarkup?url=' + url, function (markup) {

            var div = document.createElement('div');

            var title = '';
            var matches = markup.match(self.OGP_TITLE_REGEX);
            if (matches && matches.length == 2) {
                title = matches[1];
                div.innerHTML = title;
                title = $(div).html();
            }

            var image = '';
            matches = markup.match(self.TWITTER_IMAGE_REGEX);
            if (matches && matches.length == 2) {
                image = matches[1];
            } else {
                matches = markup.match(self.OGP_IMAGE_REGEX);
                if (matches && matches.length == 2) {
                    image = matches[1];
                }
            }

            var description = '';
            matches = markup.match(self.OGP_DESCRIPTION_REGEX);
            if (matches && matches.length == 2) {
                description = matches[1];
                div.innerHTML = description;
                description = $(div).html();
            }

            var a = document.createElement('a');
            a.href = url;
            var siteName = a.hostname.toUpperCase();
            matches = markup.match(self.AUTHOR_REGEX);
            if (matches && matches.length == 2) {
                 siteName += ' | ' + commons.i18n['by'] + ' ' + matches[1].toUpperCase();
            }

            if (!title && !image) {
                callback(null);
            } else {
                callback(Handlebars.templates['og_fragment']({title: title,
                                                                image: image,
                                                                url: url,
                                                                description: description,
                                                                siteName: siteName}, {helpers: commonsHelpers}));
            }
        });
    },
    addHandlersToComment: function (comment) {

        $('#commons-comment-edit-link-' + comment.id).click(commons.utils.editCommentHandler);
        $('#commons-comment-delete-link-' + comment.id).click(commons.utils.deleteCommentHandler);
        $('#commons-like-link-' + comment.id).click(commons.utils.likePostHandler);
    },
    editPostHandler: function (e) {

        var postId = this.dataset.postId;
        var contentDiv = $('#commons-post-content-' + postId);
        commons.utils.oldContent = contentDiv.html();
        contentDiv.prop('contenteditable', true).focus();
        var postEditButtons = $('#commons-post-edit-buttons-'+ postId);
        postEditButtons.show();

        $(document).ready(function () {

            $('#commons-inplace-post-editor-post-button-' + postId).off('click').click(function (e) {

                commons.utils.savePost(postId, contentDiv.html(), function () {

                        contentDiv.prop('contenteditable', false);
                        $('#commons-post-options-' + postId).show();
                        postEditButtons.hide();
                    });
                });
        });
        $('#commons-post-options-' + postId).hide();
    },
    deletePostHandler: function (e) {

        var postId = this.dataset.postId;
        commons.utils.deletePost(postId, function () {
                $('#commons-post-' + postId).remove();
            });
    },
    cancelPostEdit: function (postId) {

        var contentDiv = $('#commons-post-content-' + postId);
        contentDiv.html(this.oldContent);
        contentDiv.prop('contenteditable', false);
        $('#commons-post-options-' + postId).show();
        $('#commons-post-edit-buttons-'+ postId).hide();
    },
    editCommentHandler: function (e) {

        // Get the comment id from the link
        var commentId = this.dataset.commentId;

        var container = $('#commons-comment-' + commentId);

        var contentSpan = $('#commons-comment-content-' + commentId);

        var postId = container.data('post-id');

        // Comment metadata is attached to the container
        var comment = {
                id: commentId,
                postId: postId,
                creatorId: container.data('creator-id'),
                creatorDisplayName: container.data('creator-display-name'),
                createdDate: container.data('created-date'),
                modifiedDate: container.data('modified-date'),
                content: contentSpan.html(),
            };

        commons.utils.addPermissionsToComment(comment);

        commons.utils.commentBeingEdited = comment;
        commons.utils.renderTemplate('inplace_comment_editor', comment, 'commons-comment-' + commentId);

        $(document).ready(function () {

            var textarea = $('#commons-comment-textarea-' + comment.id);
            var tmp = commons.utils.fromHtml(comment.content);
            textarea.val(commons.utils.fromHtml(comment.content));
            textarea.each(function () { autosize(this); }).focus();

            $('#commons-inplace-comment-editor-cancel-button-' + comment.id).click(function (e) {

                commons.utils.renderTemplate(
                    'comment', commons.utils.commentBeingEdited, 'commons-comment-' + commentId);
                $('#commons-comment-edit-link-' + commentId).click(commons.utils.editCommentHandler);
            });

            $('#commons-inplace-comment-editor-post-button-' + commentId).click(function (e) {

                commons.utils.saveComment(commentId, postId, textarea.val(), function (savedComment) {

                        textarea.val('');
                        $('#commons-comments-' + postId).show();
                        commons.utils.addPermissionsToComment(savedComment);
                        commons.utils.renderTemplate('comment', savedComment, 'commons-comment-' + savedComment.id);
                        commons.utils.addHandlersToComment(savedComment);
                        commons.utils.addLikeCount(document.getElementById('commons-likes-count-' + commentId));   //re-render likesNumber after edit
                        commons.utils.getUserLikes();   //re-render Like styling for the page
                    });
            });
        });
    },
    deleteCommentHandler: function (e) {

        if (!confirm(commons.i18n['delete_comment_message'])) {
            return false;
        }

        var commentId = this.dataset.commentId;
        var postId = this.dataset.postId;
        var numComments = $('#commons-comments-' + postId + ' .commons-comment').length;
        if (numComments <= 4) {
            $('#commons-hide-comments-link-' + postId).hide();
            $('#commons-show-comments-link-' + postId).hide();
        }
        var commentToDelete = $('#commons-comment-' + commentId);

        commons.utils.deleteComment(postId, commentId, function () {

                commentToDelete.remove();
                var comments = $('#commons-comments-' + postId + ' .commons-comment');
                numComments = comments.length;
                if (numComments > 3) {
                    comments.slice(numComments - 4, numComments - 1)
                        .removeClass('comments-comment-not-recent')
                        .addClass('commons-comment-recent');
                }
            });
    },
    likePostHandler: function(){
        var postId = this.dataset.postId;
        commons.utils.likePost(postId);
        var likeButtonNow = document.getElementById('commons-like-link-' + postId);
        var likeCountNow = document.getElementById('commons-likes-count-number-' + postId);
        var likeIconNow = document.getElementById('commons-like-icon-' + postId);
        var likeNumber = parseInt(likeCountNow.getAttribute('data-count'));
        likeIconNow.classList.remove('si-like');
        likeIconNow.classList.remove('si-liked');
        if(likeButtonNow.getAttribute('class').includes('likedAlready')){
            likeNumber = likeNumber - 1;
            likeButtonNow.classList.remove('likedAlready'); //unliking
            likeIconNow.classList.add('si-like');
        } else {
            likeNumber = likeNumber + 1;
            likeButtonNow.classList.add('likedAlready');    //liking
            likeIconNow.classList.add('si-liked');
        }
        likeCountNow.textContent = likeNumber.toString();
        likeCountNow.setAttribute('data-count', likeNumber.toString());
        if(likeNumber === 1){
            document.getElementById('commons-likes-person-' + postId).removeAttribute('style');
            document.getElementById('commons-likes-people-' + postId).setAttribute('style','display:none;');
        } else {
            document.getElementById('commons-likes-people-' + postId).removeAttribute('style');
            document.getElementById('commons-likes-person-' + postId).setAttribute('style','display:none;');
        }
    },
    cancelCommentEdit: function (commentId) {

        commons.utils.renderTemplate('comment', commons.utils.commentBeingEdited, 'commons-comment-' + commentId);
        $('#commons-comment-edit-link-' + commentId).click(commons.utils.editCommentHandler);
    },
    getCurrentUserPermissions: function (callback) {

        $.ajax( {
            url: '/direct/commons/userPerms.json?siteId=' + commons.siteId + '&embedder=' + commons.embedder,
            dataType: 'json',
            cache: false,
            timeout: commons.AJAX_TIMEOUT
        }).done(function (json) {
            callback(json.data);
        }).fail(function (xmlHttpRequest, textStatus, error) {
            alert('Failed to get the current user permissions. Status: ' + textStatus + '. Error: ' + error);
        });
    },
    formatDate: function (millis) {

        if (millis <= 0) {
            return commons.i18n['none'];
        } else {
            var m = moment(millis);
            return m.format('L LT');
        }
    },
    addFormattedDatesToPosts: function (posts) {

        posts.forEach(function (p) {
            commons.utils.addFormattedDateToPost(p);
        });
    },
    addFormattedDateToPost: function (post) {

        post.formattedCreatedDate = this.formatDate(post.createdDate);
        post.formattedReleaseDate = this.formatDate(post.releaseDate);
        post.formattedModifiedDate = this.formatDate(post.modifiedDate);

        post.comments.forEach(function (c, index) {

            if (index < (post.comments.length - 3)) {
                c.orderClass = 'commons-comment-not-recent';
            } else {
                c.orderClass = 'commons-comment-recent';
                c.isRecent = true;
            }
            c.formattedCreatedDate = commons.utils.formatDate(c.createdDate);
            c.formattedModifiedDate = commons.utils.formatDate(c.modifiedDate);
        });
    },
    addFormattedDatesToCurrentPost: function () {
        this.addFormattedDateToPost(commons.currentPost);
    },
    savePost: function (postId, content, callback) {

        var success = false;
        var priority = document.getElementById('commons-editor-priority').checked;
        document.getElementById('commons-editor-priority').checked = false; //uncheck the box by default, we have what we need from it already.
        if (!postId) postId = '';

        if ('' == content) {
            alert(commons.i18n['no_content_warning']);
            return 0;
        }

        var post = {
                'id': postId,
                'content': content,
                'commonsId': commons.commonsId,
                'siteId': commons.siteId,
                'embedder': commons.embedder,
                'priority': priority
            };

        $.ajax({
            url: '/direct/commons/savePost.json',
            type: 'POST',
            data: post,
            timeout: commons.AJAX_TIMEOUT
        }).done(function (data) {
            callback(data);
        }).fail(function(xmlHttpRequest, textStatus, error) {
                alert("Failed to store post. Status: " + textStatus + '. Error: ' + error);
        });
    },
    saveComment: function (commentId, postId, content, callback) {

        content = commons.utils.toHtml(content);

        var comment = {
                'id': commentId,
                'postId': postId,
                'content': content,
                'commonsId': commons.commonsId,
                'siteId': commons.siteId,
                'embedder': commons.embedder
            };

        $.ajax( {
            url: "/direct/commons/saveComment.json",
            type: 'POST',
            data: comment,
            timeout: commons.AJAX_TIMEOUT
        }).done(function (comment) {
            callback(comment);
        }).fail(function (xmlHttpRequest, textStatus, error) {
            alert("Failed to save comment. Status: " + textStatus + '. Error: ' + error);
        });

        return false;
    },
    likePost: function(postId){
        var url = "/direct/commons/likePost?&postId=" + postId;
        $.ajax( {
            url: url,
            type: 'POST',
            data: postId,
            timeout: commons.AJAX_TIMEOUT
        }).done(function () {	
            commons.utils.getPostLikerNames(postId);
        });
    },
    deleteComment: function (postId, commentId, callback) {

        var commentCreatorId = document.getElementById('commons-comment-' + commentId).dataset.creatorId;
        var postCreatorId = document.getElementById('commons-post-' + postId).dataset.creatorId;

        var url = '/direct/commons/deleteComment?siteId=' + commons.siteId + '&commonsId=' + commons.commonsId
                        + '&postId=' + postId + '&embedder=' + commons.embedder + '&commentId=' + commentId 
                        + '&commentCreatorId=' + commentCreatorId + '&postCreatorId=' + postCreatorId;

        $.ajax( { url: url, timeout: commons.AJAX_TIMEOUT })
        .done(function (text, status) {
            callback();
        }).fail(function (xmlHttpRequest, textStatus, error) {
            alert("Failed to delete comment. Status: " + textStatus + ". Error: " + error);
        });

        return false;
    },
    deletePost: function (postId, callback) {
                        
        if (!confirm(commons.i18n['delete_post_message'])) {
            return false;
        }

        $.ajax({
            url: '/direct/commons/deletePost?postId=' + postId + '&siteId=' + commons.siteId + '&commonsId=' + commons.commonsId,
            timeout: commons.AJAX_TIMEOUT
        }).done(function (text, status) {
            callback();
        }).fail(function (xmlHttpRequest, textStatus, error) {
            alert("Failed to delete post. Status: " + textStatus + ". Error: " + error);
        });

        return false;
    },
    addPermissionsToPost: function (p) {

        p.currentUserId = commons.userId;

        p.canComment = commons.currentUserPermissions.commentCreate || commons.currentUserPermissions.commentUpdateAny;
        p.canDelete = commons.currentUserPermissions.postDeleteAny
                        || (commons.currentUserPermissions.postDeleteOwn && p.creatorId === commons.userId);
        p.canEdit = commons.currentUserPermissions.postUpdateAny
                        || (commons.currentUserPermissions.postUpdateOwn && p.creatorId === commons.userId);
        p.isModified = p.modifiedDate > p.releaseDate;

        p.comments.forEach(function (c) { commons.utils.addPermissionsToComment(c); });
    },
    addPermissionsToComment: function (c) {

        var postCreatorId = document.getElementById('commons-post-' + c.postId).dataset.creatorId;

        c.canComment = commons.currentUserPermissions.commentCreate || commons.currentUserPermissions.commentUpdateAny;
        c.modified = c.modifiedDate > c.createdDate;
        c.canDelete = commons.currentUserPermissions.commentDeleteAny
                        || (commons.currentUserPermissions.commentDeleteOwn && c.creatorId === commons.userId)
                        || (commons.embedder === 'SOCIAL' && postCreatorId === commons.userId);
        c.canEdit = commons.currentUserPermissions.commentUpdateAny
                        || (commons.currentUserPermissions.commentUpdateOwn && c.creatorId === commons.userId);
    },
    renderTemplate: function (name, data, output) {

        var template = Handlebars.templates[name];
        document.getElementById(output).innerHTML = template(data, {helpers: commonsHelpers});
    },
    renderPost: function (post, output) {

        this.addPermissionsToPost(post);
        post.currentUserId = commons.userId;

        this.renderTemplate('post', post, output);

        var self = this;

        $(document).ready(function () {

            $('#commons-post-edit-link-' + post.id).click(self.editPostHandler);
            $('#commons-post-delete-link-' + post.id).click(self.deletePostHandler);
            $('#commons-like-link-' + post.id).click(self.likePostHandler);
            var numberOfLikes = $('.commons-likes-count');
            numberOfLikes.each(function(){commons.utils.addLikeCount(this)});
            commons.utils.getUserLikes();
            bootstrap.Popover.getOrCreateInstance(document.body); // Initializes all popovers
            var textarea = $('#commons-comment-textarea-' + post.id);
            textarea.each(function () { autosize(this); });
            var creator = $('#commons-comment-creator-' + post.id);
            var commentLink = $('#commons-create-comment-link-' + post.id);
            commentLink.click(function (e) {

                creator.show();
                textarea.focus();
            });
            $('#commons-inplace-comment-editor-cancel-button-' + post.id).click(function (e) {
                creator.hide();
            });

            var showCommentsLink = $('#commons-show-comments-link-' + post.id);
            var hideCommentsLink = $('#commons-hide-comments-link-' + post.id);
            showCommentsLink.click(function (e) {

                $('#commons-comments-' + post.id + ' .commons-comment-not-recent').show();
                showCommentsLink.hide();
                hideCommentsLink.show();
            });
            hideCommentsLink.click(function (e) {

                $('#commons-comments-' + post.id + ' .commons-comment-not-recent').hide();
                hideCommentsLink.hide();
                showCommentsLink.show();
            });

            $('#commons-inplace-comment-editor-post-button-' + post.id).click(function (e) {

                commons.utils.saveComment('', post.id, textarea.val(), function (savedComment) {

                        textarea.val('');

                        var commentId = savedComment.id;

                        creator.hide();

                        var numComments = $('#commons-comments-' + post.id + ' .commons-comment').length;

                        if (numComments >= 3) {
                            var recentComments = $('#commons-comments-' + post.id + ' .commons-comment-recent');
                            recentComments.removeClass('commons-comment-recent');
                            var earliestRecentComment = $(recentComments[0]);
                            earliestRecentComment.addClass('commons-comment-not-recent');
                            if (numComments == 3 || showCommentsLink.is(':visible')) {
                                earliestRecentComment.hide();
                            }
                            recentComments[1].className += ' commons-comment-recent';
                            recentComments[2].className += ' commons-comment-recent';
                            if (numComments == 3 || showCommentsLink.is(':visible')) {
                                showCommentsLink.show();
                            }
                        }

                        commons.utils.addPermissionsToComment(savedComment);
                        savedComment.formattedCreatedDate = commons.utils.formatDate(savedComment.createdDate);
                        savedComment.orderClass = 'commons-comment-recent';
                        savedComment.isRecent = true;
                        var wrappedComment = Handlebars.templates['wrapped_comment'] (savedComment, {helpers: commonsHelpers});
                        $('#commons-comments-container-' + post.id).append(wrappedComment);

                        self.addHandlersToComment(savedComment);
                    });
            });

            if (post.comments.length <= 3) {
                showCommentsLink.hide();
            }
            if(post.priority === true){
                document.getElementById('commons-post-inner-container-' + post.id).classList.add('alert-info');
                document.getElementById('commons-high-priority-' + post.id).removeAttribute('style');
            }
            post.comments.forEach(function (c) { self.addHandlersToComment(c); });
        });
    },
    renderPageOfPosts: function (all) {

        var self = this;

        var loadImage = $('#commons-loading-image')
        loadImage.show();

        var url = '/direct/commons/posts/' + commons.commonsId + '.json?siteId='
                        + commons.siteId + '&embedder=' + commons.embedder + '&page=';
        url += (all) ? '-1' : commons.page;

        $.ajax( { url : url, dataType: "json", cache: false, timeout: commons.AJAX_TIMEOUT })
            .done(function (data) {

                if (data.status === 'END') {
                    commons.scrollable.off('scroll.commons');
                    loadImage.hide();
                } else {
                    commons.scrollable.off('scroll.commons').on('scroll.commons', commons.utils.getScrollFunction(commons.utils.renderPageOfPosts));
                }

                commons.postsTotal = data.postsTotal;
                var posts = data.posts;

                commons.currentPosts = commons.currentPosts.concat(posts);

                if (commons.page == 0 && data.postsTotal > 0) {
                    $('#commons-body-toggle').show();
                }

                commons.postsRendered += posts.length;

                commons.utils.addFormattedDatesToPosts(posts);

                // Add the next batch of placeholders to the post list
                var t = Handlebars.templates['posts_placeholders'];
                $('#commons-posts').append(t({ posts: posts }, {helpers: commonsHelpers}));

                $(document).ready(function () {

                    // Now render them into their placeholders
                    posts.forEach(function (p) { commons.utils.renderPost(p, 'commons-post-' + p.id); });

                    loadImage.hide();
                    try {
                        if (window.frameElement) {
                            setMainFrameHeight(window.frameElement.id);
                        }
                    } catch (err) {
                        // This is likely under an LTI provision scenario.
                        // XSS protection will block this call.
                    }
                });
                commons.page += 1;
            }).fail(function (xmlHttpRequest, textStatus, errorThrown) {
                alert("Failed to get posts. Reason: " + errorThrown);
            });
    },
    getScrollFunction: function (callback) {

        var scroller = function () {

            //var win = $(window);
            var wintop = commons.scrollable.scrollTop();
            var winheight = commons.scrollable.height();
            var docheight = commons.doc.height()

            if  ((wintop/(docheight-winheight)) > 0.95 || $('body').data('scroll-commons') === true) {
                $('body').data('scroll-commons', false);
                commons.scrollable.off('scroll.commons');
                callback();
            }
        };

        return scroller;
    },
    placeCaretAtEnd: function (el) {

        el.focus();
        if (typeof window.getSelection != "undefined"
                && typeof document.createRange != "undefined") {
            var range = document.createRange();
            range.selectNodeContents(el);
            range.collapse(false);
            var sel = window.getSelection();
            sel.removeAllRanges();
            sel.addRange(range);
        } else if (typeof document.body.createTextRange != "undefined") {
            var textRange = document.body.createTextRange();
            textRange.moveToElementText(el);
            textRange.collapse(false);
            textRange.select();
        }
    },
    addLikeCount: function(likesLink){
        var postId = likesLink.getAttribute('id').substring(20);
        var url = "/direct/commons/countLikes.json?&postId=" + postId;
        $.ajax({
            url: url,
            type: 'GET',
            data: postId,
            cache: false,
            timeout: commons.AJAX_TIMEOUT,
            success: function(result){
                var count = parseInt(result.data);
                if(count === 1){
                    document.getElementById('commons-likes-person-' + postId).removeAttribute('style');
                    document.getElementById('commons-likes-people-' + postId).setAttribute('style','display:none;');
                }
                document.getElementById('commons-likes-count-number-' + postId).textContent = count.toString();
                document.getElementById('commons-likes-count-number-' + postId).setAttribute('data-count', count.toString());
                commons.utils.getPostLikerNames(postId);
            }
        });
    },
    getUserLikes: function(){
        var url = "/direct/commons/userLikes.json";
        $.ajax({
            url: url,
            type: 'GET',
            cache: false,
            timeout: commons.AJAX_TIMEOUT,
            success: function(result){
                for(var count=0; count<result.commons_collection.length; count++){
                    var likeNow = document.getElementById('commons-like-link-' + result.commons_collection[count].postId);
                    var iconNow = document.getElementById('commons-like-icon-' + result.commons_collection[count].postId);
                    if(likeNow !== null){
                        iconNow.classList.remove('si-like');
                        iconNow.classList.remove('si-liked');
                        likeNow.classList.add('likedAlready');
                        iconNow.classList.add('si-liked');
                    }
                }
            }
        });
    },
    getPostLikerNames: function(postId){
        var url = "/direct/commons/postLikes.json?&postId=" + postId;
        $.ajax({
            url: url,
            type: 'GET',
            data: postId,
            cache: false,
            timeout: commons.AJAX_TIMEOUT,
            success: function(result){
                var likeNow = document.getElementById('commons-likes-count-' + postId);
                var likeNames = ``;
                for(var count=0; count<result.commons_collection.length; count++){
                    likeNames = likeNames + result.commons_collection[count].data + `<br>`;
                }
                likeNow.setAttribute('data-content', likeNames);
            }
        });
    }
};
