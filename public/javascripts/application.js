function addToDownloadQueue(post_url, video_id, title) {
  new Ajax.Request(post_url, {
parameters: { "video_id" : video_id , "title" : title},
    onSuccess: function(response) {
      alert("complete");
    },
onFailure: function(response) {
alert("failed");
}
  });
}
